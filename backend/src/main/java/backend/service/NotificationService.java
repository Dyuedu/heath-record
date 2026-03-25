package backend.service;

import backend.model.Notification;
import backend.repository.NotificationRepository;
import backend.model.dto.response.NotificationMessageDTO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class NotificationService {
    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    @Transactional(readOnly = true)
    public List<NotificationMessageDTO> getUserNotifications(UUID userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public void markAsRead(UUID notificationId, UUID userId) {
        notificationRepository.findById(notificationId).ifPresent(notification -> {
            if (notification.getUser().getId().equals(userId)) {
                notification.setRead(true);
                notificationRepository.save(notification);
            }
        });
    }

    private NotificationMessageDTO mapToDTO(Notification notif) {
        return NotificationMessageDTO.builder()
                .id(notif.getId())
                .title(notif.getTitle())
                .message(notif.getMessage())
                .patientName(extractPatientName(notif.getMessage()))
                .doctorName(notif.getDoctorName())
                .hospitalName(notif.getHospitalName())
                .recordId(notif.getRecordId())
                .isRead(notif.isRead())
                .timestamp(notif.getCreatedAt())
                .build();
    }

    private String extractPatientName(String message) {
        if (message == null) {
            return null;
        }

        String marker = " cho ";
        int markerIndex = message.lastIndexOf(marker);
        if (markerIndex < 0) {
            return null;
        }

        String candidate = message.substring(markerIndex + marker.length()).trim();
        if (candidate.endsWith(".")) {
            candidate = candidate.substring(0, candidate.length() - 1).trim();
        }

        return candidate.isEmpty() ? null : candidate;
    }
}
