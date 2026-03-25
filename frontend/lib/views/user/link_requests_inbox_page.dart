import 'package:flutter/material.dart';
import 'package:frontend/data/models/link_request/link_request_model.dart';
import 'package:frontend/utils/app_notifier.dart';
import 'package:frontend/utils/relationship_formatter.dart';
import 'package:frontend/viewmodels/link_request_viewmodel.dart';
import 'package:provider/provider.dart';

class LinkRequestsInboxPage extends StatefulWidget {
  const LinkRequestsInboxPage({super.key});

  @override
  State<LinkRequestsInboxPage> createState() => _LinkRequestsInboxPageState();
}

class _LinkRequestsInboxPageState extends State<LinkRequestsInboxPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LinkRequestViewModel>().loadInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LinkRequestViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu liên kết hồ sơ')),
      body: RefreshIndicator(
        onRefresh: () => context.read<LinkRequestViewModel>().loadInbox(),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.inboxRequests.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Không có yêu cầu nào đang chờ.')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: vm.inboxRequests.length,
                itemBuilder: (context, index) {
                  final item = vm.inboxRequests[index];
                  return _buildRequestCard(context, vm, item);
                },
              ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    LinkRequestViewModel vm,
    LinkRequestModel item,
  ) {
    final subtitle = item.requestType == 'REGISTER_LINK'
        ? 'Yêu cầu liên kết khi đăng ký tài khoản'
        : 'Yêu cầu liên kết khi thêm hồ sơ người thân';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.targetProfileName.isEmpty
                  ? 'Hồ sơ không tên'
                  : item.targetProfileName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
            if ((item.requestedRelationship ?? '').isNotEmpty)
              Text(
                'Quan hệ yêu cầu: ${formatRelationshipLabel(item.requestedRelationship)}',
              ),
            if ((item.note ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(item.note!),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: vm.isActing
                        ? null
                        : () =>
                              _handleAction(context, vm, item.requestId, false),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: vm.isActing
                        ? null
                        : () =>
                              _handleAction(context, vm, item.requestId, true),
                    child: const Text('Đồng ý'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    LinkRequestViewModel vm,
    String requestId,
    bool isApprove,
  ) async {
    final success = isApprove
        ? await vm.approve(requestId)
        : await vm.reject(requestId);

    if (!context.mounted) {
      return;
    }

    if (success) {
      await vm.loadInbox();
      if (!context.mounted) {
        return;
      }
      AppNotifier.success(
        context,
        isApprove ? 'Đã phê duyệt yêu cầu.' : 'Đã từ chối yêu cầu.',
      );
      return;
    }

    AppNotifier.error(context, vm.errorMessage ?? 'Xử lý yêu cầu thất bại.');
  }
}
