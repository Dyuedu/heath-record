package backend.service;

import backend.exception.ResourceNotFoundException;
import backend.model.Tag;
import backend.model.dto.request.TagRequest;
import backend.model.dto.response.TagResponse;
import backend.repository.TagRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TagService {

    private final TagRepository tagRepository;

    public TagService(TagRepository tagRepository) {
        this.tagRepository = tagRepository;
    }

    public List<TagResponse> getAllTags() {
        return tagRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public TagResponse createTag(TagRequest request) {
        if (tagRepository.findByName(request.name()).isPresent()) {
            throw new RuntimeException("Tên tag đã tồn tại");
        }
        Tag tag = Tag.builder()
            .name(request.name())
            .description(request.description())
            .build();
        return mapToResponse(tagRepository.save(tag));
    }

    @Transactional
    public TagResponse updateTag(Long id, TagRequest request) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tag với ID: " + id));

        tagRepository.findByName(request.name()).ifPresent(existingTag -> {
            if (!existingTag.getId().equals(id)) {
                throw new RuntimeException("Tên tag đã tồn tại");
            }
        });

        tag.setName(request.name());
        tag.setDescription(request.description());
        return mapToResponse(tagRepository.save(tag));
    }

    @Transactional
    public void deleteTag(Long id) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tag với ID: " + id));
        
        tag.setActive(false);
        tagRepository.save(tag);
    }

    private TagResponse mapToResponse(Tag tag) {
        return TagResponse.builder()
                .id(tag.getId())
                .name(tag.getName())
                .description(tag.getDescription())
                .isActive(tag.isActive())
                .build();
    }
}
