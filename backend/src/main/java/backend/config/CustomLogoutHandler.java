package backend.config;

import jakarta.annotation.Nullable;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.LogoutHandler;
import org.springframework.stereotype.Component;

import backend.service.JWTService;

import java.time.Duration;
import java.util.Date;

@Component
public class CustomLogoutHandler implements LogoutHandler {
    private final RedisTemplate<String, String> redisTemplate;
    private final JWTService jwtService;

    public CustomLogoutHandler(RedisTemplate<String, String> redisTemplate, JWTService jwtService) {
        this.redisTemplate = redisTemplate;
        this.jwtService = jwtService;
    }
    @Override
    public void logout(HttpServletRequest request, HttpServletResponse response, @Nullable Authentication authentication) {
        final String authHeader = request.getHeader("Authorization");
        if(authHeader == null || !authHeader.startsWith("Bearer ")){
            return;
        }
        String token = authHeader.substring(7);
        try {
            Date expirationDate = jwtService.extractExpiration(token);
            long diff = expirationDate.getTime() - System.currentTimeMillis();
            if(diff > 0){
                redisTemplate.opsForValue().set(token, "logout", Duration.ofMillis(diff));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        SecurityContextHolder.clearContext();
    }
}
