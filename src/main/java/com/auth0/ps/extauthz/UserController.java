package com.auth0.ps.extauthz;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;

@RestController
public class UserController {
    @GetMapping("/userinfo")
    public Principal user(Principal principal) {
        return principal;
    }
}
