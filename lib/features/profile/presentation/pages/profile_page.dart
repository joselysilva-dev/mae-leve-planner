import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/widgets/figma_icon.dart';
import '../../../../core/widgets/planner_components.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../data/profile_storage.dart';
import '../../domain/user_settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _presentation = TextEditingController();
  ProfileStorage? _storage;
  UserSettings _settings = const UserSettings();
  bool _loading = true;
  bool _saving = false;
  bool _editing = false;
  String? _error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_storage != null) return;
    _storage = ProfileStorage(AppScope.preferencesOf(context));
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _storage!.load();
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _name.text = settings.name;
        _presentation.text = settings.presentation;
        _error = null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível carregar seu perfil. Seus dados foram preservados.';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _presentation.dispose();
    super.dispose();
  }

  void _feedback(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final settings = await _storage!.saveProfile(
        name: _name.text,
        presentation: _presentation.text,
      );
      if (mounted) {
        setState(() {
          _settings = settings;
          _editing = false;
        });
      }
      _feedback('Perfil salvo com carinho.');
    } catch (_) {
      _feedback('Não foi possível salvar. Seus dados continuam no formulário.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _preference({bool? reminders, bool? care, bool? large}) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final settings = await _storage!.savePreferences(
        taskReminders: reminders,
        careBreaks: care,
        largeText: large,
      );
      if (!mounted) return;
      setState(() => _settings = settings);
      AppScope.maybeOf(context)?.onLargeTextChanged?.call(settings.largeText);
      _feedback('Preferência salva neste aparelho.');
    } catch (_) {
      _feedback('Não foi possível salvar a preferência. Tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar todos os dados?'),
        content: const Text(
          'Seu nome, preferências, tarefas, agenda e autocuidado serão apagados deste aparelho. Você voltará à apresentação inicial. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar dados'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await _storage!.clearAppData();
      if (!mounted) return;
      AppScope.maybeOf(context)?.onLargeTextChanged?.call(false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const WelcomePage()),
        (_) => false,
      );
      _feedback('Dados do aplicativo apagados.');
    } catch (_) {
      _feedback('Não foi possível limpar os dados. Tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Text(widget.embedded ? 'Perfil' : 'Perfil e configurações'),
      ),
      body: SafeArea(
        top: false,
        bottom: !widget.embedded,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.formWidth),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    key: const PageStorageKey('profile-scroll'),
                    padding: AppSpacing.page,
                    children: [
                      if (_error != null) ...[
                        Text(_error!),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Tentar novamente'),
                        ),
                      ] else ...[
                        PlannerSurface(
                          color: AppColors.primarySoft,
                          minimumHeight: 204,
                          outlined: false,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              UserAvatar(name: _settings.name),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                _settings.name.isEmpty
                                    ? 'Seu espaço de cuidado'
                                    : _settings.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _settings.presentation,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.primaryInk),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Preferências',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PlannerSurface(
                          child: Column(
                            children: [
                              SwitchListTile(
                                key: const ValueKey('profile-reminders'),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Lembretes de tarefas'),
                                subtitle: const Text(
                                  'Padrão local para novas tarefas. Não envia notificações.',
                                ),
                                value: _settings.taskReminders,
                                onChanged: _saving
                                    ? null
                                    : (value) => _preference(reminders: value),
                              ),
                              SwitchListTile(
                                key: const ValueKey('profile-care'),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Pausas de autocuidado'),
                                subtitle: const Text(
                                  'Mostrar o convite de cuidado no Início.',
                                ),
                                value: _settings.careBreaks,
                                onChanged: _saving
                                    ? null
                                    : (value) => _preference(care: value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const FigmaIcon(FigmaSymbol.accessibility),
                          title: const Text('Leitura e acessibilidade'),
                          trailing: const FigmaIcon(FigmaSymbol.profileChevron),
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Leitura e acessibilidade'),
                              content: const Text(
                                'O aplicativo respeita o tamanho de fonte do aparelho. Você também pode ativar o texto ampliado abaixo. Os controles têm áreas de toque confortáveis e rótulos para leitores de tela.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Entendi'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SwitchListTile(
                          key: const ValueKey('profile-large-text'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Texto ampliado'),
                          subtitle: const Text(
                            'Aumentar a leitura sem reduzir a fonte escolhida no aparelho.',
                          ),
                          value: _settings.largeText,
                          onChanged: _saving
                              ? null
                              : (value) => _preference(large: value),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          key: const ValueKey('edit-profile'),
                          onPressed: _saving
                              ? null
                              : () => setState(() => _editing = !_editing),
                          icon: const FigmaIcon(FigmaSymbol.editProfile),
                          label: Text(
                            _editing ? 'Fechar edição' : 'Editar meu perfil',
                          ),
                        ),
                        if (_editing) ...[
                          const SizedBox(height: AppSpacing.lg),
                          TextField(
                            key: const ValueKey('profile-name'),
                            controller: _name,
                            enabled: !_saving,
                            maxLength: 60,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Seu nome (opcional)',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            key: const ValueKey('profile-presentation'),
                            controller: _presentation,
                            enabled: !_saving,
                            maxLength: 100,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Minha apresentação (opcional)',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            key: const ValueKey('save-profile'),
                            onPressed: _saving ? null : _save,
                            child: const Text('Salvar perfil'),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Seus dados e preferências ficam reunidos em um lugar previsível.',
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.info_outline,
                          color: AppColors.primaryStrong,
                        ),
                        title: const Text('Sobre o aplicativo'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'Mãe Leve Planner',
                          applicationVersion: '1.0.0',
                          children: const [
                            Text(
                              'Projeto acadêmico desenvolvido por Josely para apresentação na DIO.',
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              'Planejamento, organização e autocuidado. Um dia de cada vez.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _clear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Limpar dados'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Center(
                        child: Text('Mãe Leve Planner · Versão 1.0.0'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}
