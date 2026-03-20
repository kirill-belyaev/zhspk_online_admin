import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/zhspk_viewmodel.dart';
import 'zhspk_create_page.dart';

class ZhspkPage extends ConsumerStatefulWidget {
  const ZhspkPage({super.key});

  @override
  ConsumerState<ZhspkPage> createState() => _ZhspkPageState();
}

class _ZhspkPageState extends ConsumerState<ZhspkPage> {
  @override
  void initState() {
    super.initState();
    // Load data after initial frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(zhspkViewModelProvider.notifier).loadZhspk();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zhspkViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('ZHSPK'),
            actions: [
              // Refresh button
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(zhspkViewModelProvider.notifier).loadZhspk(),
              ),
            ],
          ),
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null)
            SliverFillRemaining(child: _ErrorView(error: state.error!))
          else if (state.items.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No records found')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _ZhspkCard(item: state.items[index]),
                    childCount: state.items.length,
                  ),
                ),
              ),
        ],
      ),
      // Floating action button for creating new ZHSPK
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('New ZHSPK'),
      ),
    );
  }

  // Navigate to create page
  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ZhspkCreatePage()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZhspkCard extends StatelessWidget {
  final dynamic item;

  const _ZhspkCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        leading: _Avatar(logo: item.logo),
        title: Text(
          item.zhspkName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.totalSquare} m²',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        children: [
          if (item.contacts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 8),
                  Text(
                    'Contacts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...item.contacts.map((contact) => _ContactTile(contact: contact)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'No contacts available',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String logo;

  const _Avatar({required this.logo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: logo.isNotEmpty
          ? Image.network(
        _buildLogoUrl(logo),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.business,
            color: colorScheme.onPrimaryContainer,
          );
        },
      )
          : Icon(
        Icons.business,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  String _buildLogoUrl(String logoPath) {
    if (logoPath.startsWith('http')) return logoPath;
    return 'https://staging.vokrugdoma.by/$logoPath';
  }
}

class _ContactTile extends StatelessWidget {
  final dynamic contact;

  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  contact.position,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}