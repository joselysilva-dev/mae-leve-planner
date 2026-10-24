import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../../data/profile_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  ProfileStorage? _storage;
  bool _loading = true;
  bool _saving = false;
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
        _name.text = settings.name;
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
    super.dispose();
  }

  void _feedback(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _storage!.saveName(_name.text);
      _feedback('Nome salvo com carinho.');
    } catch (_) {
      _feedback('Não foi possível salvar seu nome. Tente novamente.');
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
          'Seu nome, tarefas, rotina e autocuidado serão apagados deste aparelho. Você voltará à apresentação inicial. Esta ação não pode ser desfeita.',
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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pushAndRemoveUntil(
        context,
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
      appBar: AppBar(title: const Text('Perfil e configurações')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (_error != null) ...[
                        Text(_error!),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Tentar novamente'),
                        ),
                      ] else ...[
                        const Text(
                          'Como podemos chamar você?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _name,
                          enabled: !_saving,
                          maxLength: 60,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Seu nome (opcional)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: const Text('Salvar nome'),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
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
                            SizedBox(height: 12),
                            Text(
                              'Planejamento, organização e autocuidado. Um dia de cada vez.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _clear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          minimumSize: const Size(48, 52),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Limpar dados'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}
