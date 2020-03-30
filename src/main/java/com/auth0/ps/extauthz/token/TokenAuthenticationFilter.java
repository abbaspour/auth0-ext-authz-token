package com.auth0.ps.extauthz.token;

import java.io.IOException;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

public class TokenAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(TokenAuthenticationFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String token = getToken(request);

        if(!isValid(token)){
            throw new SecurityException();
        }

        // Create our Authentication and let Spring know about it
        Authentication auth = new TokenAuthenticationToken(token);
        SecurityContextHolder.getContext().setAuthentication(auth);

        filterChain.doFilter(request, response);
    }


    private String getToken(HttpServletRequest request) {
        final String[] val = request.getParameterValues("token");
        return (val == null || val.length == 0) ? "na": val[0];
    }

    private boolean isValid(String token) {
        log.info("checking validity of remote token: " + token);
        return true;
    }
}
