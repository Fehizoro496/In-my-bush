package mg.inmybush.api.upload;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import mg.inmybush.api.config.AppProperties;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class FileStorageService {

    private final Path uploadDir;
    private final String publicBaseUrl;

    public FileStorageService(AppProperties props) {
        this.uploadDir = Paths.get(props.upload().dir()).toAbsolutePath().normalize();
        this.publicBaseUrl = props.upload().publicBaseUrl();
        try {
            Files.createDirectories(uploadDir);
        } catch (IOException e) {
            throw new RuntimeException("Impossible de créer le dossier d'upload : " + uploadDir, e);
        }
    }

    public String store(MultipartFile file) throws IOException {
        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf('.'));
        }
        String filename = UUID.randomUUID() + ext;
        Path target = uploadDir.resolve(filename).normalize();
        if (!target.startsWith(uploadDir)) {
            throw new IOException("Chemin de fichier invalide.");
        }
        try (InputStream in = file.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
        return publicBaseUrl + "/" + filename;
    }
}
