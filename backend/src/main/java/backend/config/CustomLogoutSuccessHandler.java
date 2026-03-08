package backend.config;

import jakarta.annotation.Nullable;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class CustomLogoutSuccessHandler implements LogoutSuccessHandler {
    private static final Logger logger = LoggerFactory.getLogger(CustomLogoutSuccessHandler.class);

    @Override
    public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response, @Nullable Authentication authentication) throws IOException, ServletException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String authHeader = request.getHeader("Authorization");

        if(authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            logger.warn("Unauthorized logout attempt - Token is missing or invalid");
            response.getWriter().write("{\"error\": \"Unauthorized\", \"message\": \"Token is missing or invalid!\"}");
        }
        else {
            response.setStatus(HttpServletResponse.SC_OK);
            logger.info("User successfully logged out");
            response.getWriter().write("{\"message\": \"Logout success!\"}");
            
        }
        response.getWriter().flush();
    }
}
