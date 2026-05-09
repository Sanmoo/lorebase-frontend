///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsPtBr = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ptBr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt-BR>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// pt-BR: 'Início'
	String get nav_home => 'Início';

	/// pt-BR: 'Buscar'
	String get nav_search => 'Buscar';

	/// pt-BR: 'Minhas Listas'
	String get nav_my_lists => 'Minhas Listas';

	/// pt-BR: 'Recomendar'
	String get nav_recommend => 'Recomendar';

	/// pt-BR: 'Lorebase'
	String get app_title => 'Lorebase';

	/// pt-BR: 'Bem-vindo de volta'
	String get login_welcome => 'Bem-vindo de volta';

	/// pt-BR: 'Entre para continuar suas listas'
	String get login_subtitle => 'Entre para continuar suas listas';

	/// pt-BR: 'E-mail'
	String get login_email_hint => 'E-mail';

	/// pt-BR: 'Senha'
	String get login_password_hint => 'Senha';

	/// pt-BR: 'Entrar'
	String get login_button => 'Entrar';

	/// pt-BR: 'Esqueceu a senha?'
	String get login_forgot_password => 'Esqueceu a senha?';

	/// pt-BR: 'Não tem conta? '
	String get login_no_account => 'Não tem conta? ';

	/// pt-BR: 'Cadastre-se'
	String get login_sign_up => 'Cadastre-se';

	/// pt-BR: 'ou'
	String get login_or => 'ou';

	/// pt-BR: 'Buscar séries...'
	String get search_hint => 'Buscar séries...';

	/// pt-BR: 'Digite pelo menos 2 caracteres para buscar'
	String get search_empty => 'Digite pelo menos 2 caracteres para buscar';

	/// pt-BR: 'Nenhuma série encontrada'
	String get search_no_results => 'Nenhuma série encontrada';

	/// pt-BR: 'Quero Ver'
	String get tracking_want_to_watch => 'Quero Ver';

	/// pt-BR: 'Assistindo'
	String get tracking_watching => 'Assistindo';

	/// pt-BR: 'Concluído'
	String get tracking_completed => 'Concluído';

	/// pt-BR: 'Abandonado'
	String get tracking_dropped => 'Abandonado';

	/// pt-BR: 'Nenhuma série {status} ainda'
	String get tracking_empty => 'Nenhuma série {status} ainda';

	/// pt-BR: 'Minhas Listas'
	String get tracking_list_title => 'Minhas Listas';

	/// pt-BR: 'Adicionar à Lista'
	String get series_detail_add_to_list => 'Adicionar à Lista';

	/// pt-BR: 'Gerenciar'
	String get series_detail_manage_tracking => 'Gerenciar';

	/// pt-BR: 'Visão Geral'
	String get series_detail_overview => 'Visão Geral';

	/// pt-BR: 'Nenhuma descrição disponível.'
	String get series_detail_no_description => 'Nenhuma descrição disponível.';

	/// pt-BR: 'Mostrar mais'
	String get series_detail_show_more => 'Mostrar mais';

	/// pt-BR: 'Mostrar menos'
	String get series_detail_show_less => 'Mostrar menos';

	/// pt-BR: 'Primeira Exibição'
	String get series_detail_first_air_date => 'Primeira Exibição';

	/// pt-BR: 'Temporadas'
	String get series_detail_seasons => 'Temporadas';

	/// pt-BR: 'Redes'
	String get series_detail_networks => 'Redes';

	/// pt-BR: 'Status'
	String get series_detail_status => 'Status';

	/// pt-BR: 'Avaliação'
	String get series_detail_rating => 'Avaliação';

	/// pt-BR: 'Review (opcional)'
	String get series_detail_review => 'Review (opcional)';

	/// pt-BR: 'Salvar Alterações'
	String get series_detail_save_changes => 'Salvar Alterações';

	/// pt-BR: 'Remover da Lista'
	String get series_detail_remove_from_list => 'Remover da Lista';

	/// pt-BR: 'Remover "{title}" da sua lista?'
	String get series_detail_remove_confirm => 'Remover "{title}" da sua lista?';

	/// pt-BR: 'Cancelar'
	String get series_detail_cancel => 'Cancelar';

	/// pt-BR: 'Remover'
	String get series_detail_remove => 'Remover';

	/// pt-BR: 'Carregando detalhes da série...'
	String get series_detail_loading => 'Carregando detalhes da série...';

	/// pt-BR: '{count} {count, plural, one{temporada} other{temporadas}}'
	String get series_detail_season_count => '{count} {count, plural, one{temporada} other{temporadas}}';

	/// pt-BR: 'Carregando seu dashboard...'
	String get dashboard_loading => 'Carregando seu dashboard...';

	/// pt-BR: 'Nenhuma série registrada ainda. Busque e adicione sua primeira série!'
	String get dashboard_empty => 'Nenhuma série registrada ainda.\nBusque e adicione sua primeira série!';

	/// pt-BR: 'Assistindo'
	String get dashboard_watching => 'Assistindo';

	/// pt-BR: 'Quero Ver'
	String get dashboard_want_to_watch => 'Quero Ver';

	/// pt-BR: 'Concluído'
	String get dashboard_completed => 'Concluído';

	/// pt-BR: 'Abandonado'
	String get dashboard_dropped => 'Abandonado';

	/// pt-BR: 'Criar conta'
	String get auth_create_account => 'Criar conta';

	/// pt-BR: 'Confirme seu e-mail'
	String get auth_confirm_email => 'Confirme seu e-mail';

	/// pt-BR: 'Digite o código enviado para {email}'
	String get auth_code_sent_to => 'Digite o código enviado para {email}';

	/// pt-BR: 'Código de confirmação'
	String get auth_confirmation_code => 'Código de confirmação';

	/// pt-BR: 'Confirmar e entrar'
	String get auth_confirm_and_login => 'Confirmar e entrar';

	/// pt-BR: 'Reenviar código'
	String get auth_resend_code => 'Reenviar código';

	/// pt-BR: 'Fraca'
	String get auth_password_weak => 'Fraca';

	/// pt-BR: 'Média'
	String get auth_password_medium => 'Média';

	/// pt-BR: 'Forte'
	String get auth_password_strong => 'Forte';

	/// pt-BR: 'Li e aceito os Termos de Uso'
	String get auth_accept_terms => 'Li e aceito os Termos de Uso';

	/// pt-BR: 'Já tem conta? '
	String get auth_already_have_account => 'Já tem conta? ';

	/// pt-BR: 'Entrar'
	String get auth_sign_in => 'Entrar';

	/// pt-BR: 'Recuperar senha'
	String get auth_recover_password => 'Recuperar senha';

	/// pt-BR: 'Nova senha'
	String get auth_new_password_title => 'Nova senha';

	/// pt-BR: 'E-mail'
	String get auth_email_hint => 'E-mail';

	/// pt-BR: 'Senha'
	String get auth_password_hint => 'Senha';

	/// pt-BR: 'Confirmar senha'
	String get auth_confirm_password_hint => 'Confirmar senha';

	/// pt-BR: 'Enviar código'
	String get auth_send_code => 'Enviar código';

	/// pt-BR: 'Código de verificação'
	String get auth_verification_code_hint => 'Código de verificação';

	/// pt-BR: 'Nova senha'
	String get auth_new_password_hint => 'Nova senha';

	/// pt-BR: 'Confirmar nova senha'
	String get auth_confirm_new_password_hint => 'Confirmar nova senha';

	/// pt-BR: 'Redefinir senha'
	String get auth_reset_password => 'Redefinir senha';

	/// pt-BR: 'Código enviado para seu e-mail'
	String get auth_code_sent_success => 'Código enviado para seu e-mail';

	/// pt-BR: 'Senha redefinida com sucesso'
	String get auth_password_reset_success => 'Senha redefinida com sucesso';

	/// pt-BR: 'Voltar para o login'
	String get auth_back_to_login => 'Voltar para o login';

	/// pt-BR: 'Cadastre-se'
	String get auth_sign_up => 'Cadastre-se';

	/// pt-BR: 'Digite seu e-mail para receber um código de verificação'
	String get auth_forgot_subtitle_request => 'Digite seu e-mail para receber um código de verificação';

	/// pt-BR: 'Digite o código enviado para seu e-mail e sua nova senha'
	String get auth_forgot_subtitle_reset => 'Digite o código enviado para seu e-mail e sua nova senha';

	/// pt-BR: 'Português'
	String get locale_pt_BR => 'Português';

	/// pt-BR: 'English'
	String get locale_en_US => 'English';

	/// pt-BR: 'Español'
	String get locale_es => 'Español';

	/// pt-BR: 'Recomendação'
	String get recommend_title => 'Recomendação';

	/// pt-BR: 'Funcionalidade de recomendação em breve!'
	String get recommend_coming_soon => 'Funcionalidade de recomendação em breve!';

	/// pt-BR: 'Erro de rede. Verifique sua conexão.'
	String get error_network => 'Erro de rede. Verifique sua conexão.';

	/// pt-BR: 'Erro no servidor. Tente novamente mais tarde.'
	String get error_server => 'Erro no servidor. Tente novamente mais tarde.';

	/// pt-BR: 'Sessão expirada. Faça login novamente.'
	String get error_session_expired => 'Sessão expirada. Faça login novamente.';

	/// pt-BR: 'Recurso não encontrado.'
	String get error_resource_not_found => 'Recurso não encontrado.';
}

/// The flat map containing all translations for locale <pt-BR>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'nav_home' => 'Início',
			'nav_search' => 'Buscar',
			'nav_my_lists' => 'Minhas Listas',
			'nav_recommend' => 'Recomendar',
			'app_title' => 'Lorebase',
			'login_welcome' => 'Bem-vindo de volta',
			'login_subtitle' => 'Entre para continuar suas listas',
			'login_email_hint' => 'E-mail',
			'login_password_hint' => 'Senha',
			'login_button' => 'Entrar',
			'login_forgot_password' => 'Esqueceu a senha?',
			'login_no_account' => 'Não tem conta? ',
			'login_sign_up' => 'Cadastre-se',
			'login_or' => 'ou',
			'search_hint' => 'Buscar séries...',
			'search_empty' => 'Digite pelo menos 2 caracteres para buscar',
			'search_no_results' => 'Nenhuma série encontrada',
			'tracking_want_to_watch' => 'Quero Ver',
			'tracking_watching' => 'Assistindo',
			'tracking_completed' => 'Concluído',
			'tracking_dropped' => 'Abandonado',
			'tracking_empty' => 'Nenhuma série {status} ainda',
			'tracking_list_title' => 'Minhas Listas',
			'series_detail_add_to_list' => 'Adicionar à Lista',
			'series_detail_manage_tracking' => 'Gerenciar',
			'series_detail_overview' => 'Visão Geral',
			'series_detail_no_description' => 'Nenhuma descrição disponível.',
			'series_detail_show_more' => 'Mostrar mais',
			'series_detail_show_less' => 'Mostrar menos',
			'series_detail_first_air_date' => 'Primeira Exibição',
			'series_detail_seasons' => 'Temporadas',
			'series_detail_networks' => 'Redes',
			'series_detail_status' => 'Status',
			'series_detail_rating' => 'Avaliação',
			'series_detail_review' => 'Review (opcional)',
			'series_detail_save_changes' => 'Salvar Alterações',
			'series_detail_remove_from_list' => 'Remover da Lista',
			'series_detail_remove_confirm' => 'Remover "{title}" da sua lista?',
			'series_detail_cancel' => 'Cancelar',
			'series_detail_remove' => 'Remover',
			'series_detail_loading' => 'Carregando detalhes da série...',
			'series_detail_season_count' => '{count} {count, plural, one{temporada} other{temporadas}}',
			'dashboard_loading' => 'Carregando seu dashboard...',
			'dashboard_empty' => 'Nenhuma série registrada ainda.\nBusque e adicione sua primeira série!',
			'dashboard_watching' => 'Assistindo',
			'dashboard_want_to_watch' => 'Quero Ver',
			'dashboard_completed' => 'Concluído',
			'dashboard_dropped' => 'Abandonado',
			'auth_create_account' => 'Criar conta',
			'auth_confirm_email' => 'Confirme seu e-mail',
			'auth_code_sent_to' => 'Digite o código enviado para {email}',
			'auth_confirmation_code' => 'Código de confirmação',
			'auth_confirm_and_login' => 'Confirmar e entrar',
			'auth_resend_code' => 'Reenviar código',
			'auth_password_weak' => 'Fraca',
			'auth_password_medium' => 'Média',
			'auth_password_strong' => 'Forte',
			'auth_accept_terms' => 'Li e aceito os Termos de Uso',
			'auth_already_have_account' => 'Já tem conta? ',
			'auth_sign_in' => 'Entrar',
			'auth_recover_password' => 'Recuperar senha',
			'auth_new_password_title' => 'Nova senha',
			'auth_email_hint' => 'E-mail',
			'auth_password_hint' => 'Senha',
			'auth_confirm_password_hint' => 'Confirmar senha',
			'auth_send_code' => 'Enviar código',
			'auth_verification_code_hint' => 'Código de verificação',
			'auth_new_password_hint' => 'Nova senha',
			'auth_confirm_new_password_hint' => 'Confirmar nova senha',
			'auth_reset_password' => 'Redefinir senha',
			'auth_code_sent_success' => 'Código enviado para seu e-mail',
			'auth_password_reset_success' => 'Senha redefinida com sucesso',
			'auth_back_to_login' => 'Voltar para o login',
			'auth_sign_up' => 'Cadastre-se',
			'auth_forgot_subtitle_request' => 'Digite seu e-mail para receber um código de verificação',
			'auth_forgot_subtitle_reset' => 'Digite o código enviado para seu e-mail e sua nova senha',
			'locale_pt_BR' => 'Português',
			'locale_en_US' => 'English',
			'locale_es' => 'Español',
			'recommend_title' => 'Recomendação',
			'recommend_coming_soon' => 'Funcionalidade de recomendação em breve!',
			'error_network' => 'Erro de rede. Verifique sua conexão.',
			'error_server' => 'Erro no servidor. Tente novamente mais tarde.',
			'error_session_expired' => 'Sessão expirada. Faça login novamente.',
			'error_resource_not_found' => 'Recurso não encontrado.',
			_ => null,
		};
	}
}
