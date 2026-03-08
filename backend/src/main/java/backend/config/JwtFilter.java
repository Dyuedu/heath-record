package backend.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import lombok.NonNull;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import backend.service.CustomUserDetailService;
import backend.service.JWTService;

import java.io.IOException;
import java.util.UUID;

@Component
public class JwtFilter extends OncePerRequestFilter {

    private final JWTService jwtService;
    private final CustomUserDetailService userDetailsService;
    private final RedisTemplate<String, String> redisTemplate;

    public JwtFilter(JWTService jwtService, CustomUserDetailService userDetailsService, RedisTemplate<String, String> redisTemplate) {
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
        this.redisTemplate = redisTemplate;
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        String token = "";
        UUID userId = null;
        // nếu là google thì bỏ qua, không check jwt
        if (request.getServletPath().contains("/api/auth/google")) {
            filterChain.doFilter(request, response);
            return;
        }
        if (header != null && header.startsWith("Bearer ")) {
            token = header.substring(7);
            userId = UUID.fromString(jwtService.extractUserId(token));
        }
        Boolean isLogout = redisTemplate.hasKey(token);
        if(Boolean.TRUE.equals(isLogout)){
            SecurityContextHolder.clearContext();
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if (userId != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = userDetailsService.loadUserById(userId);
            if (jwtService.isTokenValid(token, userDetails)) {
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );
                // Gắn thêm thông tin request (IP, Browser...)
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        filterChain.doFilter(request, response);
    }
}
