# Ke hoach chi tiet: Yeu cau cho phep lien ket Profile khi trung CCCD/So dien thoai

## 1. Muc tieu nghiep vu

- Khi dang ky tai khoan moi hoac them ho so nguoi than, neu he thong phat hien profile da ton tai theo CCCD hoac so dien thoai, khong tao profile moi.
- Thay vao do, tao yeu cau lien ket gui den nguoi dang quan ly profile hien tai de phe duyet.
- Chi khi owner phe duyet thi tai khoan moi hoac quan he nguoi than moi duoc gan vao profile do.

## 2. Pham vi thay doi

- Backend Spring Boot:
    - Them bang yeu cau lien ket profile.
    - Them API tao yeu cau, lay danh sach, phe duyet, tu choi.
    - Refactor luong dang ky va them nguoi than.
- Frontend Flutter:
    - Cap nhat data layer va viewmodel de xu ly ket qua phan nhanh.
    - Them man hinh inbox yeu cau cho owner.
    - Them thong bao trang thai cho requester.
- Test:
    - Unit test + integration test cho luong dong bo va canh tranh du lieu.

## 3. Quy tac nghiep vu chi tiet

### 3.1 Quy tac tim profile trung

- Uu tien match theo CCCD (identityNumber) neu request co CCCD hop le.
- Neu khong co CCCD hoac CCCD khong trung thi moi fallback match theo so dien thoai profile.
- Chuan hoa truoc khi so sanh:
    - trim khoang trang dau/cuoi
    - bo khoang trang giua ky tu
    - so dien thoai: bo dau +84 -> 0 (neu team thong nhat rule nay)

### 3.2 Quy tac tao yeu cau

- Moi cap requester + targetProfile chi duoc ton tai 1 request PENDING.
- Request co han (de xuat: 7 ngay), qua han thi EXPIRED.
- Trang thai request:
    - PENDING
    - APPROVED
    - REJECTED
    - EXPIRED
    - CANCELLED (tu requester hoac he thong)

### 3.3 Quy tac phe duyet

- Chi owner (nguoi dang so huu quan he voi profile) duoc phe duyet/tu choi.
- Approve phai chay trong transaction:
    - Validate request van PENDING va chua het han.
    - Gan profile cho requester (dang ky moi) hoac tao relative moi (them nguoi than).
    - Dong tat ca request PENDING khac cung cap requester + profile (set CANCELLED).
    - Set request hien tai thanh APPROVED va luu respondedAt.

## 4. Thiet ke du lieu

### 4.1 Bang moi: profile_link_requests

- id (UUID)
- requester_user_id (UUID, not null)
- owner_user_id (UUID, not null)
- target_profile_id (UUID, not null)
- request_type (REGISTER_LINK | ADD_RELATIVE_LINK)
- requested_relationship (nullable, dung cho add relative)
- note (nullable)
- status (enum)
- expires_at (timestamp)
- responded_at (timestamp, nullable)
- created_at, updated_at

### 4.2 Index va rang buoc

- index owner_user_id + status (hien thi inbox nhanh)
- index requester_user_id + status (hien thi outbox nhanh)
- index target_profile_id + status
- unique logic cho PENDING duplicate (xu ly bang service + transaction; neu can co the dung unique partial index tuy DB)

### 4.3 Repository bo sung

- ProfileRepository:
    - findFirstByIdentityNumber(...)
    - findFirstByPhoneNumber(...)
- ProfileLinkRequestRepository:
    - findByOwnerUserIdAndStatusOrderByCreatedAtDesc(...)
    - findByRequesterUserIdAndStatusOrderByCreatedAtDesc(...)
    - existsByRequesterUserIdAndTargetProfileIdAndStatus(...)

## 5. Ke hoach API

### 5.1 API tao request trong luong dang ky

- Endpoint hien tai: POST /api/auth/register
- Hanh vi moi:
    - Neu khong trung: van tao user + profile + relative Me nhu cu.
    - Neu trung profile:
        - Tao user (chua link profile)
        - Tao request PENDING
        - Tra ve response phan nhanh.

De xuat response:

- Success tao tai khoan binh thuong:
    - status: REGISTERED
- Tao request lien ket:
    - status: LINK_REQUEST_CREATED
    - requestId
    - message

### 5.2 API tao request trong luong them nguoi than

- Endpoint hien tai: POST /api/relatives
- Hanh vi moi:
    - Khong trung: tao relative + profile moi nhu cu.
    - Trung profile:
        - Tao request PENDING voi request_type = ADD_RELATIVE_LINK
        - Khong tao relative ngay
        - Tra ve status LINK_REQUEST_CREATED.

### 5.3 API cho owner xu ly

- GET /api/link-requests/inbox?status=PENDING
- GET /api/link-requests/outbox?status=PENDING
- POST /api/link-requests/{id}/approve
- POST /api/link-requests/{id}/reject
- POST /api/link-requests/{id}/cancel (optional)

Approve response de xuat:

- status: APPROVED
- requestId
- linkedProfileId
- message

Reject response de xuat:

- status: REJECTED
- requestId
- message

## 6. Ke hoach backend theo phase

### Phase A: Nen tang du lieu

- Tao entity ProfileLinkRequest.
- Tao enum RequestType, RequestStatus.
- Tao repository + migration SQL.

### Phase B: Domain service

- Tao LinkRequestService:
    - detectDuplicateProfile(...)
    - createLinkRequest(...)
    - approve(...)
    - reject(...)
    - expireOldPendingRequests(...)

### Phase C: Refactor dang ky

- Refactor AuthService.register:
    - Tach logic tao account thuong.
    - Chen nhanh tao request khi trung profile.
    - Doi contract response tu void -> DTO response.
- Cap nhat AuthController tra DTO moi.

### Phase D: Refactor them nguoi than

- Refactor RelativeService.addRelative:
    - Kiem tra trung profile theo rule.
    - Tao request thay vi tao profile moi.
    - Doi response tu RelativeResponse thuong sang DTO phan nhanh.

### Phase E: Controller cho request

- Tao LinkRequestController:
    - inbox/outbox
    - approve/reject/cancel
- Them phan quyen ro rang cho owner/requester.

### Phase F: Xu ly dong bo va canh tranh

- Them optimistic lock version field cho request (neu can).
- Hoac dung select for update trong approve/reject transaction.
- Dam bao approve/reject 2 lan chi cho phep 1 lan dau.

## 7. Ke hoach frontend theo phase

### Phase A: Data layer

- Them model:
    - LinkRequestModel
    - AddRelativeResultModel
    - RegisterResultModel
- Update repository methods de parse response status.

### Phase B: ViewModel

- ProfileViewModel.addRelative:
    - Doi kieu tra ve tu bool sang object ket qua.
    - Xu ly 3 nhanh: CREATED, LINK_REQUEST_CREATED, ERROR.
- AuthViewModel.register:
    - Xu ly nhanh LINK_REQUEST_CREATED.

### Phase C: UI

- AddProfilePage:
    - Neu LINK_REQUEST_CREATED -> hien snackbar/thong bao cho nguoi dung.
- SignupPage:
    - Neu LINK_REQUEST_CREATED -> dieu huong sang man hinh cho duyet hoac thong bao.
- Them man hinh Link Requests Inbox:
    - danh sach PENDING
    - nut Dong y / Tu choi

### Phase D: Dong bo sau thao tac

- Sau approve/reject, refresh inbox.
- Sau requester tao request, refresh outbox neu co man hinh theo doi.

## 8. Bao mat va an toan du lieu

- Khong tra thong tin nhay cam cua owner cho requester (chi thong diep chung).
- Log audit cho hanh dong tao/phe duyet/tu choi request.
- Rate limit tao request de tranh spam.
- Validate chat che CCCD/phone format de giam false positive.

## 9. Ke hoach test

### 9.1 Backend unit test

- detectDuplicateProfile: dung uu tien CCCD.
- createLinkRequest: chan duplicate pending.
- approve/reject: dung quyen owner.

### 9.2 Backend integration test

- Dang ky moi khong trung -> REGISTERED.
- Dang ky trung -> LINK_REQUEST_CREATED.
- Add relative trung -> LINK_REQUEST_CREATED.
- Owner approve -> lien ket thanh cong.
- Owner reject -> khong lien ket.
- Request het han -> khong cho approve.

### 9.3 Frontend test

- ViewModel parse dung status response.
- UI hien dung thong bao tung nhanh.
- Inbox action cap nhat state dung.

## 10. Ke hoach trien khai va rollback

- Release theo feature flag: enableProfileLinkApproval.
- Bat backend truoc, sau do cap nhat frontend.
- Monitoring:
    - so request tao moi/ngay
    - ti le approve/reject
    - thoi gian xu ly trung binh
- Rollback:
    - tat feature flag, quay ve luong cu (khong dung request approval).

## 11. Danh sach cong viec cu the

### Backend

- [ ] Tao migration bang profile_link_requests
- [ ] Tao entity/repository/enum
- [ ] Tao LinkRequestService
- [ ] Refactor AuthService + AuthController response moi
- [ ] Refactor RelativeService + RecordController response moi
- [ ] Tao LinkRequestController
- [ ] Bo sung validation + authz
- [ ] Viet test unit + integration

### Frontend

- [ ] Tao model ket qua dang ky/them relative
- [ ] Update repository parse response status
- [ ] Update ProfileViewModel/AuthViewModel
- [ ] Update AddProfilePage + SignupPage
- [ ] Tao inbox page cho owner
- [ ] Viet test viewmodel/widget

### Ops

- [ ] Them env/flag cau hinh
- [ ] Them dashboard monitor
- [ ] Chuan bi runbook rollback

## 12. Uoc tinh thoi gian

- Backend core + migration + test: 4-6 ngay
- Frontend flow + UI + test: 3-4 ngay
- QA end-to-end + bugfix: 2-3 ngay
- Tong: 9-13 ngay lam viec

## 13. Rui ro va giam thieu

- Rui ro match nham profile:
    - Giam thieu: uu tien CCCD, validate format, normalize du lieu.
- Rui ro race condition approve/reject:
    - Giam thieu: transaction + lock + check status truoc khi update.
- Rui ro pha vo API cu:
    - Giam thieu: version DTO hoac support backward-compatible trong 1 release.
