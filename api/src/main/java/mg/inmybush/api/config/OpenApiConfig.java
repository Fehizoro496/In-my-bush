package mg.inmybush.api.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

/** Swagger UI at /swagger-ui.html; "Authorize" with the access token returned by /auth/login. */
@Configuration
@OpenAPIDefinition(
    info = @Info(title = "In my bush API", version = "v1",
        description = "Marketplace de produits bio — API REST. Montants en Ariary (entiers)."),
    security = @SecurityRequirement(name = "bearerAuth"))
@SecurityScheme(name = "bearerAuth", type = SecuritySchemeType.HTTP, scheme = "bearer", bearerFormat = "JWT")
public class OpenApiConfig {
}
