///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsPtBr with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPtBr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
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
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsPtBr _root = this; // ignore: unused_field

	@override 
	TranslationsPtBr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPtBr(meta: meta ?? this.$meta);

	// Translations
	@override String get nav_home => 'Início';
	@override String get nav_search => 'Buscar';
	@override String get nav_my_lists => 'Minhas Listas';
	@override String get nav_recommend => 'Recomendar';
	@override String get app_title => 'Lorebase';
	@override String get login_welcome => 'Bem-vindo de volta';
	@override String get login_subtitle => 'Entre para continuar suas listas';
	@override String get login_email_hint => 'E-mail';
	@override String get login_password_hint => 'Senha';
	@override String get login_button => 'Entrar';
	@override String get login_forgot_password => 'Esqueceu a senha?';
	@override String get login_no_account => 'Não tem conta? ';
	@override String get login_sign_up => 'Cadastre-se';
	@override String get login_or => 'ou';
	@override String get search_hint => 'Buscar séries...';
	@override String get search_empty => 'Digite pelo menos 2 caracteres para buscar';
	@override String get search_no_results => 'Nenhuma série encontrada';
	@override String get tracking_want_to_watch => 'Quero Ver';
	@override String get tracking_watching => 'Assistindo';
	@override String get tracking_completed => 'Concluído';
	@override String get tracking_dropped => 'Abandonado';
	@override String get tracking_empty => 'Nenhuma série {status} ainda';
	@override String get tracking_list_title => 'Minhas Listas';
	@override String get series_detail_add_to_list => 'Adicionar à Lista';
	@override String get series_detail_manage_tracking => 'Gerenciar';
	@override String get series_detail_overview => 'Visão Geral';
	@override String get series_detail_no_description => 'Nenhuma descrição disponível.';
	@override String get series_detail_show_more => 'Mostrar mais';
	@override String get series_detail_show_less => 'Mostrar menos';
	@override String get series_detail_first_air_date => 'Primeira Exibição';
	@override String get series_detail_seasons => 'Temporadas';
	@override String get series_detail_networks => 'Redes';
	@override String get series_detail_status => 'Status';
	@override String get series_detail_rating => 'Avaliação';
	@override String get series_detail_review => 'Review (opcional)';
	@override String get series_detail_save_changes => 'Salvar Alterações';
	@override String get series_detail_remove_from_list => 'Remover da Lista';
	@override String get series_detail_remove_confirm => 'Remover "{title}" da sua lista?';
	@override String get series_detail_cancel => 'Cancelar';
	@override String get series_detail_remove => 'Remover';
	@override String get series_detail_loading => 'Carregando detalhes da série...';
	@override String get series_detail_season_count => '{count} {count, plural, one{temporada} other{temporadas}}';
	@override String get dashboard_loading => 'Carregando seu dashboard...';
	@override String get dashboard_empty => 'Nenhuma série registrada ainda.\nBusque e adicione sua primeira série!';
	@override String get dashboard_watching => 'Assistindo';
	@override String get dashboard_want_to_watch => 'Quero Ver';
	@override String get dashboard_completed => 'Concluído';
	@override String get dashboard_dropped => 'Abandonado';
	@override String get auth_create_account => 'Criar conta';
	@override String get auth_confirm_email => 'Confirme seu e-mail';
	@override String get auth_code_sent_to => 'Digite o código enviado para {email}';
	@override String get auth_confirmation_code => 'Código de confirmação';
	@override String get auth_confirm_and_login => 'Confirmar e entrar';
	@override String get auth_resend_code => 'Reenviar código';
	@override String get auth_password_weak => 'Fraca';
	@override String get auth_password_medium => 'Média';
	@override String get auth_password_strong => 'Forte';
	@override String get auth_accept_terms => 'Li e aceito os Termos de Uso';
	@override String get auth_already_have_account => 'Já tem conta? ';
	@override String get auth_sign_in => 'Entrar';
	@override String get auth_recover_password => 'Recuperar senha';
	@override String get auth_new_password_title => 'Nova senha';
	@override String get auth_email_hint => 'E-mail';
	@override String get auth_password_hint => 'Senha';
	@override String get auth_confirm_password_hint => 'Confirmar senha';
	@override String get auth_send_code => 'Enviar código';
	@override String get auth_verification_code_hint => 'Código de verificação';
	@override String get auth_new_password_hint => 'Nova senha';
	@override String get auth_confirm_new_password_hint => 'Confirmar nova senha';
	@override String get auth_reset_password => 'Redefinir senha';
	@override String get auth_code_sent_success => 'Código enviado para seu e-mail';
	@override String get auth_password_reset_success => 'Senha redefinida com sucesso';
	@override String get auth_back_to_login => 'Voltar para o login';
	@override String get auth_sign_up => 'Cadastre-se';
	@override String get auth_forgot_subtitle_request => 'Digite seu e-mail para receber um código de verificação';
	@override String get auth_forgot_subtitle_reset => 'Digite o código enviado para seu e-mail e sua nova senha';
	@override String get locale_pt_BR => 'Português';
	@override String get locale_en_US => 'English';
	@override String get locale_es => 'Español';
	@override String get recommend_title => 'Recomendação';
	@override String get recommend_coming_soon => 'Funcionalidade de recomendação em breve!';
	@override String get error_network => 'Erro de rede. Verifique sua conexão.';
	@override String get error_server => 'Erro no servidor. Tente novamente mais tarde.';
	@override String get error_session_expired => 'Sessão expirada. Faça login novamente.';
	@override String get error_resource_not_found => 'Recurso não encontrado.';
}

/// The flat map containing all translations for locale <pt-BR>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPtBr {
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
