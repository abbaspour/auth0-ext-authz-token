package com.auth0.ps.extauthz.token;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import static java.util.Collections.singleton;

public class TokenAuthenticationToken extends AbstractAuthenticationToken {

    private final String principal;

    public TokenAuthenticationToken(String token) {
        super(singleton(new SimpleGrantedAuthority("USER")));
        this.principal = token;
        super.setAuthenticated(true);

    }

    @Override
    public Object getCredentials() {
        return "";
    }

    @Override
    public Object getPrincipal() {
        return principal;
    }
}
