package mg.inmybush.api.upload.service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import mg.inmybush.api.common.BadRequestException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UploadService {

    private static final long MAX_SIZE = 5 * 1024 * 1024; // 5 MB
    private static final List<String> ALLOWED_TYPES = List.of("image/jpeg", "image/png", "image/webp", "image/gif");

    private final FileStorageService fileStorageService;

    public UploadService(FileStorageService fileStorageService) {
        this.fileStorageService = fileStorageService;
    }

    public List<String> uploadImages(List<MultipartFile> files) {
        if (files == null || files.isEmpty()) {
            throw new BadRequestException("NO_FILES", "Aucun fichier fourni.");
        }
        List<String> urls = new ArrayList<>();
        for (MultipartFile file : files) {
            if (file.isEmpty()) continue;
            if (file.getSize() > MAX_SIZE) {
                throw new BadRequestException("FILE_TOO_LARGE", "Le fichier dépasse la taille maximale de 5 Mo.");
            }
            String contentType = file.getContentType();
            if (contentType == null || !ALLOWED_TYPES.contains(contentType)) {
                throw new BadRequestException("INVALID_FILE_TYPE", "Type de fichier non autorisé : " + contentType);
            }
            try {
                urls.add(fileStorageService.store(file));
            } catch (IOException e) {
                throw new BadRequestException("UPLOAD_ERROR", "Erreur lors de l'envoi du fichier : " + e.getMessage());
            }
        }
        return urls;
    }
}
