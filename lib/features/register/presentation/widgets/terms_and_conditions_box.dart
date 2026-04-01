import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_bloc.dart';
import 'package:portfolio_mobile_app/features/register/bloc/register_event.dart';

class TermsAndConditionsBox extends StatefulWidget {
  const TermsAndConditionsBox({super.key});

  @override
  State<TermsAndConditionsBox> createState() => _TermsAndConditionsBoxState();
}

class _TermsAndConditionsBoxState extends State<TermsAndConditionsBox> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _loadTerms(BuildContext context) {
    return DefaultAssetBundle.of(
      context,
    ).loadString('assets/register_terms_and_conditions.md');
  }

  void _handleScroll() {
    if (!mounted) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    final maxExtent = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final reachedBottom = maxExtent == 0 || offset >= maxExtent - 8;
    final bloc = context.read<RegisterBloc>();
    if (bloc.state.hasReachedTermsEnd == reachedBottom) {
      return;
    }
    bloc.add(RegisterTermsScrollChanged(hasReachedEnd: reachedBottom));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Terminos y condiciones de uso',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<String>(
            future: _loadTerms(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text(
                  'No fue posible cargar los terminos.',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }

              final textTheme = Theme.of(context).textTheme;

              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _handleScroll(),
              );

              return Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: MarkdownBody(
                    data: snapshot.data ?? '',
                    styleSheet: AppTheme.termsMarkdownStyleSheet(textTheme),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
