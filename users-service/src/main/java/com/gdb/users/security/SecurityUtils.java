package com.gdb.users.security;

import com.gdb.users.constants.UserConstants;

public class SecurityUtils {

    public static void checkAdminRole() {
        UserContext context = UserContextHolder.getContext();
        if (context == null || !UserConstants.ROLE_ADMIN.equals(context.getRole())) {
            throw new RuntimeException("ACCESS_DENIED");
        }
    }

    // Fixed MOD8-BUG-01: Corrected logical operator from || to &&
    public static void checkAdminOrTellerRole() {
        UserContext context = UserContextHolder.getContext();
        if (context == null)
            throw new RuntimeException("ACCESS_DENIED");

        String role = context.getRole();
        // Corrected logic: deny only if the role is neither ADMIN nor TELLER
        if (!UserConstants.ROLE_ADMIN.equals(role) && !UserConstants.ROLE_TELLER.equals(role)) {
            throw new RuntimeException("ACCESS_DENIED");
        }
    }

    public static void checkAnyAuthorizedRole() {
        UserContext context = UserContextHolder.getContext();
        if (context == null) {
            throw new RuntimeException("ACCESS_DENIED");
        }
    }
}
