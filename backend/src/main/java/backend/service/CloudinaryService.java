package backend.service;

import backend.exception.FileUploadException;
import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CloudinaryService {

    private final Cloudinary cloudinary;

    public String uploadFile(MultipartFile file) {

        if (file == null || file.isEmpty()) {
            throw new FileUploadException("File is empty");
        }

        try {

            Map<String, Object> uploaded = cloudinary.uploader().upload(
                    file.getBytes(),
                    ObjectUtils.asMap("folder", "health-records")
            );

            return uploaded.get("secure_url").toString();

        } catch (IOException e) {
            throw new FileUploadException("Không thể tải tệp lên Cloudinary", e);
        }
    }
}