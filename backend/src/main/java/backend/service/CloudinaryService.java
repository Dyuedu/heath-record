package backend.service;

import backend.exception.InvalidRequestException;
import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class CloudinaryService {
    private static final long MAX_IMAGE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB
    private static final Set<String> ALLOWED_CONTENT_TYPES =
            Set.of("image/jpeg", "image/png", "image/webp", "image/jpg");

    private final Cloudinary cloudinary;

    public CloudinaryService(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    public String uploadAvatar(UUID userId, MultipartFile file) {
        validateFile(file);
        try {
            Map<?, ?> uploadResult = cloudinary.uploader().upload(
                    file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", "health-record/avatars",
                            "public_id", "user_" + userId,
                            "overwrite", true,
                            "resource_type", "image"));

            Object secureUrl = uploadResult.get("secure_url");
            if (secureUrl == null) {
                throw new InvalidRequestException(
                        "AVATAR_UPLOAD_FAILED", "Không thể tải ảnh lên Cloudinary.");
            }

            return secureUrl.toString();
        } catch (IOException exception) {
            throw new InvalidRequestException(
                    "AVATAR_UPLOAD_FAILED", "Không thể tải ảnh lên Cloudinary, vui lòng thử lại.");
        }
    }

    public String uploadImage(MultipartFile file) {
        validateFile(file);
        try {
            Map<?, ?> uploadResult = cloudinary.uploader().upload(
                    file.getBytes(),
                    ObjectUtils.asMap(
                            "folder", "health-record/uploads",
                            "public_id", "record_" + UUID.randomUUID(),
                            "resource_type", "image"));

            Object secureUrl = uploadResult.get("secure_url");
            if (secureUrl == null) {
                throw new InvalidRequestException(
                        "IMAGE_UPLOAD_FAILED", "Không thể tải ảnh lên Cloudinary.");
            }

            return secureUrl.toString();
        } catch (IOException exception) {
            throw new InvalidRequestException(
                    "IMAGE_UPLOAD_FAILED", "Không thể tải ảnh lên Cloudinary, vui lòng thử lại.");
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new InvalidRequestException("AVATAR_REQUIRED", "Vui lòng chọn ảnh đại diện.");
        }
        if (file.getSize() > MAX_IMAGE_SIZE_BYTES) {
            throw new InvalidRequestException("AVATAR_TOO_LARGE", "Ảnh đại diện phải nhỏ hơn 5MB.");
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase())) {
            throw new InvalidRequestException(
                    "AVATAR_INVALID_TYPE", "Chỉ chấp nhận ảnh JPEG, JPG, PNG hoặc WEBP.");
        }
    }
}
