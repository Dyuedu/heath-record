package backend.controller;

import backend.service.CloudinaryService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class UploadController {

    private final CloudinaryService cloudinaryService;

    public UploadController(CloudinaryService cloudinaryService) {
        this.cloudinaryService = cloudinaryService;
    }

    @PostMapping("/v1/upload")
    @PreAuthorize("hasRole('DOCTOR')")
    public ResponseEntity<Map<String, String>> uploadImage(@RequestPart("file") MultipartFile file) {
        String url = cloudinaryService.uploadImage(file);
        return ResponseEntity.ok(Map.of("url", url));
    }
}
