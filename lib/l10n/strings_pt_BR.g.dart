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

	/// pt-BR: 'Social'
	String get nav_social => 'Social';

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

	/// pt-BR: 'Buscar jogos...'
	String get search_hint_games => 'Buscar jogos...';

	/// pt-BR: 'Digite pelo menos 2 caracteres para buscar'
	String get search_empty => 'Digite pelo menos 2 caracteres para buscar';

	/// pt-BR: 'Nenhuma série encontrada'
	String get search_no_results => 'Nenhuma série encontrada';

	/// pt-BR: 'Nenhum jogo encontrado'
	String get search_no_results_games => 'Nenhum jogo encontrado';

	/// pt-BR: 'Quero Ver'
	String get tracking_want_to_watch => 'Quero Ver';

	/// pt-BR: 'Assistindo'
	String get tracking_watching => 'Assistindo';

	/// pt-BR: 'Concluído'
	String get tracking_completed => 'Concluído';

	/// pt-BR: 'Abandonado'
	String get tracking_dropped => 'Abandonado';

	/// pt-BR: 'Quero Jogar'
	String get tracking_want_to_play_game => 'Quero Jogar';

	/// pt-BR: 'Jogando'
	String get tracking_playing_game => 'Jogando';

	/// pt-BR: 'Concluído'
	String get tracking_completed_game => 'Concluído';

	/// pt-BR: 'Abandonado'
	String get tracking_dropped_game => 'Abandonado';

	/// pt-BR: 'Nenhuma série {status} ainda'
	String get tracking_empty => 'Nenhuma série {status} ainda';

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

	/// pt-BR: 'Episódios'
	String get series_detail_episodes => 'Episódios';

	/// pt-BR: 'Nota TMDB'
	String get series_detail_tmdb_rating => 'Nota TMDB';

	/// pt-BR: '$count votos'
	String series_detail_vote_count({required Object count}) => '${count} votos';

	/// pt-BR: 'Mais detalhes'
	String get series_detail_more_details => 'Mais detalhes';

	/// pt-BR: 'Criado por'
	String get series_detail_created_by => 'Criado por';

	/// pt-BR: 'País de origem'
	String get series_detail_origin_country => 'País de origem';

	/// pt-BR: 'Tipo'
	String get series_detail_type => 'Tipo';

	/// pt-BR: 'Popularidade'
	String get series_detail_popularity => 'Popularidade';

	/// pt-BR: 'Último episódio'
	String get series_detail_last_episode => 'Último episódio';

	/// pt-BR: 'Próximo episódio'
	String get series_detail_next_episode => 'Próximo episódio';

	/// pt-BR: 'T${season}E$episode'
	String series_detail_episode_code({required Object season, required Object episode}) => 'T${season}E${episode}';

	/// pt-BR: '{code} · {date}'
	String get series_detail_episode_date => '{code} · {date}';

	/// pt-BR: '—'
	String get series_detail_not_available => '—';

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

	/// pt-BR: 'Remover "$title" da sua lista?'
	String series_detail_remove_confirm({required Object title}) => 'Remover "${title}" da sua lista?';

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

	/// pt-BR: 'Séries'
	String get media_type_series => 'Séries';

	/// pt-BR: 'Filmes'
	String get media_type_movies => 'Filmes';

	/// pt-BR: 'Jogos'
	String get media_type_games => 'Jogos';

	/// pt-BR: 'Buscar filmes...'
	String get search_hint_movies => 'Buscar filmes...';

	/// pt-BR: 'Nenhum filme encontrado'
	String get search_no_results_movies => 'Nenhum filme encontrado';

	/// pt-BR: 'Nenhum filme {status} ainda'
	String get tracking_empty_movies => 'Nenhum filme {status} ainda';

	/// pt-BR: 'Nenhum filme registrado ainda. Busque e adicione seu primeiro filme!'
	String get dashboard_empty_movies => 'Nenhum filme registrado ainda.\nBusque e adicione seu primeiro filme!';

	/// pt-BR: 'Erro: $message'
	String movie_detail_error({required Object message}) => 'Erro: ${message}';

	/// pt-BR: 'Carregando detalhes do filme...'
	String get movie_detail_loading => 'Carregando detalhes do filme...';

	/// pt-BR: 'Data de Lançamento'
	String get movie_detail_release_date => 'Data de Lançamento';

	/// pt-BR: 'Duração'
	String get movie_detail_runtime => 'Duração';

	/// pt-BR: '{minutes} min'
	String get movie_detail_runtime_minutes => '{minutes} min';

	/// pt-BR: 'Funcionalidade de recomendação em breve!'
	String get recommend_coming_soon => 'Funcionalidade de recomendação em breve!';

	/// pt-BR: 'Tentar novamente'
	String get error_retry => 'Tentar novamente';

	/// pt-BR: 'Erro de rede. Verifique sua conexão.'
	String get error_network => 'Erro de rede. Verifique sua conexão.';

	/// pt-BR: 'Erro no servidor. Tente novamente mais tarde.'
	String get error_server => 'Erro no servidor. Tente novamente mais tarde.';

	/// pt-BR: 'Sessão expirada. Faça login novamente.'
	String get error_session_expired => 'Sessão expirada. Faça login novamente.';

	/// pt-BR: 'Recurso não encontrado.'
	String get error_resource_not_found => 'Recurso não encontrado.';

	/// pt-BR: 'Não foi possível carregar o Social.'
	String get social_load_error => 'Não foi possível carregar o Social.';

	/// pt-BR: 'Meu perfil →'
	String get social_my_profile => 'Meu perfil →';

	/// pt-BR: 'Erro ao carregar feed.'
	String get social_feed_load_error => 'Erro ao carregar feed.';

	/// pt-BR: 'Nenhuma sugestão por enquanto.'
	String get social_discover_empty => 'Nenhuma sugestão por enquanto.';

	/// pt-BR: 'Não foi possível seguir este usuário.'
	String get social_follow_error => 'Não foi possível seguir este usuário.';

	/// pt-BR: 'Tentar novamente'
	String get social_try_again => 'Tentar novamente';

	/// pt-BR: 'Nome de exibição'
	String get social_display_name => 'Nome de exibição';

	/// pt-BR: 'URL do avatar'
	String get social_avatar_url => 'URL do avatar';

	/// pt-BR: 'Privacidade'
	String get social_privacy => 'Privacidade';

	/// pt-BR: 'Público'
	String get social_public => 'Público';

	/// pt-BR: 'Privado'
	String get social_private => 'Privado';

	/// pt-BR: 'Salvar perfil'
	String get social_save_profile => 'Salvar perfil';

	/// pt-BR: 'Finalizar'
	String get social_finish => 'Finalizar';

	/// pt-BR: 'Descobrir pessoas'
	String get social_discover_people_cta => 'Descobrir pessoas';

	/// pt-BR: 'Editar perfil'
	String get social_edit_profile => 'Editar perfil';

	/// pt-BR: 'Perfil público'
	String get social_public_profile => 'Perfil público';

	/// pt-BR: 'Salvar alterações'
	String get social_save_changes => 'Salvar alterações';

	/// pt-BR: 'Não foi possível carregar seu perfil social.'
	String get social_profile_load_error => 'Não foi possível carregar seu perfil social.';

	/// pt-BR: 'Não foi possível salvar o perfil. Tente novamente.'
	String get social_profile_save_error => 'Não foi possível salvar o perfil. Tente novamente.';

	/// pt-BR: 'Nenhuma pessoa para mostrar.'
	String get social_empty_people => 'Nenhuma pessoa para mostrar.';

	/// pt-BR: 'Erro ao carregar lista.'
	String get social_list_load_error => 'Erro ao carregar lista.';

	/// pt-BR: 'Atividade'
	String get social_activity => 'Atividade';

	/// pt-BR: 'Listas'
	String get social_lists => 'Listas';

	/// pt-BR: 'Seguidores'
	String get social_followers => 'Seguidores';

	/// pt-BR: 'Seguindo'
	String get social_following => 'Seguindo';

	/// pt-BR: 'Este perfil não está disponível no momento.'
	String get social_profile_unavailable => 'Este perfil não está disponível no momento.';

	/// pt-BR: 'Nenhuma atividade pública ainda.'
	String get social_empty_public_activity => 'Nenhuma atividade pública ainda.';

	/// pt-BR: 'Não foi possível carregar a atividade deste perfil.'
	String get social_profile_activity_load_error => 'Não foi possível carregar a atividade deste perfil.';

	/// pt-BR: 'Não foi possível carregar $section.'
	String social_section_load_error({required Object section}) => 'Não foi possível carregar ${section}.';

	/// pt-BR: 'Carregando $section...'
	String social_section_loading({required Object section}) => 'Carregando ${section}...';

	/// pt-BR: '(one) {$count seguidor} (other) {$count seguidores}'
	String social_followers_count({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(count,
		one: '${count} seguidor',
		other: '${count} seguidores',
	);

	/// pt-BR: '$count seguindo'
	String social_following_count({required Object count}) => '${count} seguindo';

	/// pt-BR: '$percent% de afinidade'
	String social_affinity({required Object percent}) => '${percent}% de afinidade';

	/// pt-BR: 'Seguir'
	String get social_follow => 'Seguir';

	/// pt-BR: 'Deixar de seguir'
	String get social_unfollow => 'Deixar de seguir';

	/// pt-BR: 'Atualizando seguir'
	String get social_follow_updating_semantics => 'Atualizando seguir';

	/// pt-BR: 'Seguindo'
	String get social_following_action => 'Seguindo';

	/// pt-BR: 'Seguindo usuário'
	String get social_following_user_semantics => 'Seguindo usuário';

	/// pt-BR: 'Feed'
	String get social_feed => 'Feed';

	/// pt-BR: 'Descobrir'
	String get social_discover => 'Descobrir';

	/// pt-BR: 'Seu feed ainda está quieto'
	String get social_empty_feed_title => 'Seu feed ainda está quieto';

	/// pt-BR: 'Siga pessoas para ver avaliações, reviews e atividades recentes.'
	String get social_empty_feed_body => 'Siga pessoas para ver avaliações, reviews e atividades recentes.';

	/// pt-BR: 'Descobrir pessoas'
	String get social_discover_people => 'Descobrir pessoas';

	/// pt-BR: 'Crie seu perfil social'
	String get social_create_profile_title => 'Crie seu perfil social';

	/// pt-BR: 'Informe um nome de exibição'
	String get social_display_name_required => 'Informe um nome de exibição';

	/// pt-BR: 'Escolha a privacidade do perfil'
	String get social_privacy_required => 'Escolha a privacidade do perfil';

	/// pt-BR: 'Sugestões para seguir'
	String get social_follow_suggestions => 'Sugestões para seguir';

	/// pt-BR: 'O Discover demorou para responder. Tente novamente em instantes.'
	String get social_discover_timeout => 'O Discover demorou para responder. Tente novamente em instantes.';

	/// pt-BR: 'Erro ao descobrir pessoas.'
	String get social_discover_error => 'Erro ao descobrir pessoas.';

	/// pt-BR: 'Editar perfil social'
	String get social_edit_profile_title => 'Editar perfil social';

	/// pt-BR: 'Listas públicas'
	String get social_public_lists_title => 'Listas públicas';

	/// pt-BR: 'Quero ver'
	String get social_status_plan_to_watch => 'Quero ver';

	/// pt-BR: 'Assistindo'
	String get social_status_watching => 'Assistindo';

	/// pt-BR: 'Concluído'
	String get social_status_completed => 'Concluído';

	/// pt-BR: 'Abandonado'
	String get social_status_dropped => 'Abandonado';

	/// pt-BR: 'Nenhum item em $section.'
	String social_public_list_empty({required Object section}) => 'Nenhum item em ${section}.';

	/// pt-BR: 'Atividade social'
	String get dashboard_social_preview_title => 'Atividade social';

	/// pt-BR: 'Veja o que outros fãs estão assistindo e avaliando.'
	String get dashboard_social_preview_body => 'Veja o que outros fãs estão assistindo e avaliando.';

	/// pt-BR: 'Abrir Social'
	String get dashboard_social_preview_cta => 'Abrir Social';

	/// pt-BR: 'Recomendações para você'
	String get dashboard_recommendation_title => 'Recomendações para você';

	/// pt-BR: 'Encontre algo personalizado para assistir em seguida.'
	String get dashboard_recommendation_body => 'Encontre algo personalizado para assistir em seguida.';

	/// pt-BR: 'Receber recomendações'
	String get dashboard_recommendation_cta => 'Receber recomendações';

	/// pt-BR: 'Alterar idioma'
	String get nav_change_language_tooltip => 'Alterar idioma';

	/// pt-BR: 'Sair'
	String get nav_sign_out_tooltip => 'Sair';

	/// pt-BR: 'Limpar busca'
	String get search_clear_tooltip => 'Limpar busca';

	/// pt-BR: 'Reenviar código de confirmação'
	String get auth_resend_confirmation_code => 'Reenviar código de confirmação';

	/// pt-BR: 'Nenhum item público ainda.'
	String get social_public_list_empty_default => 'Nenhum item público ainda.';

	/// pt-BR: 'Abrir $title'
	String social_open_media_semantics({required Object title}) => 'Abrir ${title}';

	/// pt-BR: 'Filme'
	String get social_media_type_movie => 'Filme';

	/// pt-BR: 'Série'
	String get social_media_type_series => 'Série';

	/// pt-BR: 'Perfil social: $name'
	String dashboard_social_profile_label({required Object name}) => 'Perfil social: ${name}';

	/// pt-BR: 'avaliou'
	String get social_activity_rated => 'avaliou';

	/// pt-BR: 'escreveu uma review de'
	String get social_activity_reviewed => 'escreveu uma review de';

	/// pt-BR: 'completou'
	String get social_activity_completed => 'completou';

	/// pt-BR: 'começou'
	String get social_activity_started_watching => 'começou';

	/// pt-BR: 'abandonou'
	String get social_activity_dropped => 'abandonou';

	/// pt-BR: 'adicionou à lista'
	String get social_activity_added_to_list => 'adicionou à lista';

	/// pt-BR: 'interagiu com'
	String get social_activity_interacted_with => 'interagiu com';

	/// pt-BR: 'Preencha e-mail e senha'
	String get auth_error_email_password_required => 'Preencha e-mail e senha';

	/// pt-BR: 'E-mail ou senha incorretos'
	String get auth_error_invalid_credentials => 'E-mail ou senha incorretos';

	/// pt-BR: 'Digite seu e-mail'
	String get auth_error_email_required => 'Digite seu e-mail';

	/// pt-BR: 'Erro ao enviar código. Tente novamente.'
	String get auth_error_send_code => 'Erro ao enviar código. Tente novamente.';

	/// pt-BR: 'As senhas não coincidem'
	String get auth_error_passwords_do_not_match => 'As senhas não coincidem';

	/// pt-BR: 'Preencha todos os campos'
	String get auth_error_fill_all_fields => 'Preencha todos os campos';

	/// pt-BR: 'Erro ao redefinir senha. Tente novamente.'
	String get auth_error_reset_password => 'Erro ao redefinir senha. Tente novamente.';

	/// pt-BR: 'A senha é muito fraca'
	String get auth_error_password_too_weak => 'A senha é muito fraca';

	/// pt-BR: 'Aceite os termos de uso'
	String get auth_error_accept_terms => 'Aceite os termos de uso';

	/// pt-BR: 'Este email já está cadastrado. Faça login ou use outro email.'
	String get auth_error_email_already_registered => 'Este email já está cadastrado. Faça login ou use outro email.';

	/// pt-BR: 'Erro ao criar conta. Tente novamente.'
	String get auth_error_create_account => 'Erro ao criar conta. Tente novamente.';

	/// pt-BR: 'Digite o código de confirmação'
	String get auth_error_confirmation_code_required => 'Digite o código de confirmação';

	/// pt-BR: 'Código inválido. Tente novamente.'
	String get auth_error_invalid_code => 'Código inválido. Tente novamente.';

	/// pt-BR: 'Não foi possível reenviar o código. Tente novamente.'
	String get auth_error_resend_code => 'Não foi possível reenviar o código. Tente novamente.';

	/// pt-BR: 'Alterar foto'
	String get social_change_photo => 'Alterar foto';

	/// pt-BR: 'Escolher da galeria'
	String get social_choose_from_gallery => 'Escolher da galeria';

	/// pt-BR: 'Tirar foto'
	String get social_take_photo => 'Tirar foto';

	/// pt-BR: 'Cancelar'
	String get social_cancel => 'Cancelar';

	/// pt-BR: 'Foto do perfil atualizada'
	String get social_avatar_updated_success => 'Foto do perfil atualizada';

	/// pt-BR: 'Não foi possível atualizar o avatar'
	String get social_avatar_update_failure => 'Não foi possível atualizar o avatar';

	/// pt-BR: 'Não foi possível acessar a câmera ou galeria. Verifique as permissões e tente novamente.'
	String get social_avatar_access_failure => 'Não foi possível acessar a câmera ou galeria. Verifique as permissões e tente novamente.';

	/// pt-BR: 'O avatar deve ser JPEG, PNG ou WebP'
	String get social_avatar_invalid_type => 'O avatar deve ser JPEG, PNG ou WebP';

	/// pt-BR: 'O arquivo do avatar deve ter 10 MB ou menos'
	String get social_avatar_size_limit => 'O arquivo do avatar deve ter 10 MB ou menos';

	/// pt-BR: 'Editar avatar'
	String get social_edit_avatar_semantics => 'Editar avatar';

	/// pt-BR: 'Enviando avatar'
	String get social_avatar_uploading_semantics => 'Enviando avatar';

	/// pt-BR: 'PC'
	String get game_platform_pc => 'PC';

	/// pt-BR: 'Switch'
	String get game_platform_switch => 'Switch';

	/// pt-BR: 'Switch 2'
	String get game_platform_switch2 => 'Switch 2';

	/// pt-BR: 'PS1'
	String get game_platform_ps1 => 'PS1';

	/// pt-BR: 'PS2'
	String get game_platform_ps2 => 'PS2';

	/// pt-BR: 'PS3'
	String get game_platform_ps3 => 'PS3';

	/// pt-BR: 'PS4'
	String get game_platform_ps4 => 'PS4';

	/// pt-BR: 'PS5'
	String get game_platform_ps5 => 'PS5';

	/// pt-BR: 'Xbox'
	String get game_platform_xbox => 'Xbox';

	/// pt-BR: 'Xbox 360'
	String get game_platform_xbox_360 => 'Xbox 360';

	/// pt-BR: 'Xbox One'
	String get game_platform_xbox_one => 'Xbox One';

	/// pt-BR: 'SNES'
	String get game_platform_snes => 'SNES';

	/// pt-BR: 'NES'
	String get game_platform_nes => 'NES';

	/// pt-BR: 'Mega Drive'
	String get game_platform_mega_drive => 'Mega Drive';

	/// pt-BR: 'GBA'
	String get game_platform_gba => 'GBA';

	/// pt-BR: 'Xbox Series X/S'
	String get game_platform_xbox_series_xs => 'Xbox Series X/S';

	/// pt-BR: 'Mobile'
	String get game_platform_mobile => 'Mobile';

	/// pt-BR: 'VR'
	String get game_platform_vr => 'VR';

	/// pt-BR: 'Outro'
	String get game_platform_other => 'Outro';

	/// pt-BR: 'Horas jogadas'
	String get game_hours_played_label => 'Horas jogadas';
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
			'nav_social' => 'Social',
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
			'search_hint_games' => 'Buscar jogos...',
			'search_empty' => 'Digite pelo menos 2 caracteres para buscar',
			'search_no_results' => 'Nenhuma série encontrada',
			'search_no_results_games' => 'Nenhum jogo encontrado',
			'tracking_want_to_watch' => 'Quero Ver',
			'tracking_watching' => 'Assistindo',
			'tracking_completed' => 'Concluído',
			'tracking_dropped' => 'Abandonado',
			'tracking_want_to_play_game' => 'Quero Jogar',
			'tracking_playing_game' => 'Jogando',
			'tracking_completed_game' => 'Concluído',
			'tracking_dropped_game' => 'Abandonado',
			'tracking_empty' => 'Nenhuma série {status} ainda',
			'series_detail_add_to_list' => 'Adicionar à Lista',
			'series_detail_manage_tracking' => 'Gerenciar',
			'series_detail_overview' => 'Visão Geral',
			'series_detail_no_description' => 'Nenhuma descrição disponível.',
			'series_detail_show_more' => 'Mostrar mais',
			'series_detail_show_less' => 'Mostrar menos',
			'series_detail_episodes' => 'Episódios',
			'series_detail_tmdb_rating' => 'Nota TMDB',
			'series_detail_vote_count' => ({required Object count}) => '${count} votos',
			'series_detail_more_details' => 'Mais detalhes',
			'series_detail_created_by' => 'Criado por',
			'series_detail_origin_country' => 'País de origem',
			'series_detail_type' => 'Tipo',
			'series_detail_popularity' => 'Popularidade',
			'series_detail_last_episode' => 'Último episódio',
			'series_detail_next_episode' => 'Próximo episódio',
			'series_detail_episode_code' => ({required Object season, required Object episode}) => 'T${season}E${episode}',
			'series_detail_episode_date' => '{code} · {date}',
			'series_detail_not_available' => '—',
			'series_detail_first_air_date' => 'Primeira Exibição',
			'series_detail_seasons' => 'Temporadas',
			'series_detail_networks' => 'Redes',
			'series_detail_status' => 'Status',
			'series_detail_rating' => 'Avaliação',
			'series_detail_review' => 'Review (opcional)',
			'series_detail_save_changes' => 'Salvar Alterações',
			'series_detail_remove_from_list' => 'Remover da Lista',
			'series_detail_remove_confirm' => ({required Object title}) => 'Remover "${title}" da sua lista?',
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
			'media_type_series' => 'Séries',
			'media_type_movies' => 'Filmes',
			'media_type_games' => 'Jogos',
			'search_hint_movies' => 'Buscar filmes...',
			'search_no_results_movies' => 'Nenhum filme encontrado',
			'tracking_empty_movies' => 'Nenhum filme {status} ainda',
			'dashboard_empty_movies' => 'Nenhum filme registrado ainda.\nBusque e adicione seu primeiro filme!',
			'movie_detail_error' => ({required Object message}) => 'Erro: ${message}',
			'movie_detail_loading' => 'Carregando detalhes do filme...',
			'movie_detail_release_date' => 'Data de Lançamento',
			'movie_detail_runtime' => 'Duração',
			'movie_detail_runtime_minutes' => '{minutes} min',
			'recommend_coming_soon' => 'Funcionalidade de recomendação em breve!',
			'error_retry' => 'Tentar novamente',
			'error_network' => 'Erro de rede. Verifique sua conexão.',
			'error_server' => 'Erro no servidor. Tente novamente mais tarde.',
			'error_session_expired' => 'Sessão expirada. Faça login novamente.',
			'error_resource_not_found' => 'Recurso não encontrado.',
			'social_load_error' => 'Não foi possível carregar o Social.',
			'social_my_profile' => 'Meu perfil →',
			'social_feed_load_error' => 'Erro ao carregar feed.',
			'social_discover_empty' => 'Nenhuma sugestão por enquanto.',
			'social_follow_error' => 'Não foi possível seguir este usuário.',
			'social_try_again' => 'Tentar novamente',
			'social_display_name' => 'Nome de exibição',
			'social_avatar_url' => 'URL do avatar',
			'social_privacy' => 'Privacidade',
			'social_public' => 'Público',
			'social_private' => 'Privado',
			'social_save_profile' => 'Salvar perfil',
			'social_finish' => 'Finalizar',
			'social_discover_people_cta' => 'Descobrir pessoas',
			'social_edit_profile' => 'Editar perfil',
			'social_public_profile' => 'Perfil público',
			'social_save_changes' => 'Salvar alterações',
			'social_profile_load_error' => 'Não foi possível carregar seu perfil social.',
			'social_profile_save_error' => 'Não foi possível salvar o perfil. Tente novamente.',
			'social_empty_people' => 'Nenhuma pessoa para mostrar.',
			'social_list_load_error' => 'Erro ao carregar lista.',
			'social_activity' => 'Atividade',
			'social_lists' => 'Listas',
			'social_followers' => 'Seguidores',
			'social_following' => 'Seguindo',
			'social_profile_unavailable' => 'Este perfil não está disponível no momento.',
			'social_empty_public_activity' => 'Nenhuma atividade pública ainda.',
			'social_profile_activity_load_error' => 'Não foi possível carregar a atividade deste perfil.',
			'social_section_load_error' => ({required Object section}) => 'Não foi possível carregar ${section}.',
			'social_section_loading' => ({required Object section}) => 'Carregando ${section}...',
			'social_followers_count' => ({required num count}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(count, one: '${count} seguidor', other: '${count} seguidores', ), 
			'social_following_count' => ({required Object count}) => '${count} seguindo',
			'social_affinity' => ({required Object percent}) => '${percent}% de afinidade',
			'social_follow' => 'Seguir',
			'social_unfollow' => 'Deixar de seguir',
			'social_follow_updating_semantics' => 'Atualizando seguir',
			'social_following_action' => 'Seguindo',
			'social_following_user_semantics' => 'Seguindo usuário',
			'social_feed' => 'Feed',
			'social_discover' => 'Descobrir',
			'social_empty_feed_title' => 'Seu feed ainda está quieto',
			'social_empty_feed_body' => 'Siga pessoas para ver avaliações, reviews e atividades recentes.',
			'social_discover_people' => 'Descobrir pessoas',
			'social_create_profile_title' => 'Crie seu perfil social',
			'social_display_name_required' => 'Informe um nome de exibição',
			'social_privacy_required' => 'Escolha a privacidade do perfil',
			'social_follow_suggestions' => 'Sugestões para seguir',
			'social_discover_timeout' => 'O Discover demorou para responder. Tente novamente em instantes.',
			'social_discover_error' => 'Erro ao descobrir pessoas.',
			'social_edit_profile_title' => 'Editar perfil social',
			'social_public_lists_title' => 'Listas públicas',
			'social_status_plan_to_watch' => 'Quero ver',
			'social_status_watching' => 'Assistindo',
			'social_status_completed' => 'Concluído',
			'social_status_dropped' => 'Abandonado',
			'social_public_list_empty' => ({required Object section}) => 'Nenhum item em ${section}.',
			'dashboard_social_preview_title' => 'Atividade social',
			'dashboard_social_preview_body' => 'Veja o que outros fãs estão assistindo e avaliando.',
			'dashboard_social_preview_cta' => 'Abrir Social',
			'dashboard_recommendation_title' => 'Recomendações para você',
			'dashboard_recommendation_body' => 'Encontre algo personalizado para assistir em seguida.',
			'dashboard_recommendation_cta' => 'Receber recomendações',
			'nav_change_language_tooltip' => 'Alterar idioma',
			'nav_sign_out_tooltip' => 'Sair',
			'search_clear_tooltip' => 'Limpar busca',
			'auth_resend_confirmation_code' => 'Reenviar código de confirmação',
			'social_public_list_empty_default' => 'Nenhum item público ainda.',
			'social_open_media_semantics' => ({required Object title}) => 'Abrir ${title}',
			'social_media_type_movie' => 'Filme',
			'social_media_type_series' => 'Série',
			'dashboard_social_profile_label' => ({required Object name}) => 'Perfil social: ${name}',
			'social_activity_rated' => 'avaliou',
			'social_activity_reviewed' => 'escreveu uma review de',
			'social_activity_completed' => 'completou',
			'social_activity_started_watching' => 'começou',
			'social_activity_dropped' => 'abandonou',
			'social_activity_added_to_list' => 'adicionou à lista',
			'social_activity_interacted_with' => 'interagiu com',
			'auth_error_email_password_required' => 'Preencha e-mail e senha',
			'auth_error_invalid_credentials' => 'E-mail ou senha incorretos',
			'auth_error_email_required' => 'Digite seu e-mail',
			'auth_error_send_code' => 'Erro ao enviar código. Tente novamente.',
			'auth_error_passwords_do_not_match' => 'As senhas não coincidem',
			'auth_error_fill_all_fields' => 'Preencha todos os campos',
			'auth_error_reset_password' => 'Erro ao redefinir senha. Tente novamente.',
			'auth_error_password_too_weak' => 'A senha é muito fraca',
			'auth_error_accept_terms' => 'Aceite os termos de uso',
			'auth_error_email_already_registered' => 'Este email já está cadastrado. Faça login ou use outro email.',
			'auth_error_create_account' => 'Erro ao criar conta. Tente novamente.',
			'auth_error_confirmation_code_required' => 'Digite o código de confirmação',
			'auth_error_invalid_code' => 'Código inválido. Tente novamente.',
			'auth_error_resend_code' => 'Não foi possível reenviar o código. Tente novamente.',
			'social_change_photo' => 'Alterar foto',
			'social_choose_from_gallery' => 'Escolher da galeria',
			'social_take_photo' => 'Tirar foto',
			'social_cancel' => 'Cancelar',
			'social_avatar_updated_success' => 'Foto do perfil atualizada',
			'social_avatar_update_failure' => 'Não foi possível atualizar o avatar',
			'social_avatar_access_failure' => 'Não foi possível acessar a câmera ou galeria. Verifique as permissões e tente novamente.',
			'social_avatar_invalid_type' => 'O avatar deve ser JPEG, PNG ou WebP',
			'social_avatar_size_limit' => 'O arquivo do avatar deve ter 10 MB ou menos',
			'social_edit_avatar_semantics' => 'Editar avatar',
			'social_avatar_uploading_semantics' => 'Enviando avatar',
			'game_platform_pc' => 'PC',
			'game_platform_switch' => 'Switch',
			'game_platform_switch2' => 'Switch 2',
			'game_platform_ps1' => 'PS1',
			'game_platform_ps2' => 'PS2',
			'game_platform_ps3' => 'PS3',
			'game_platform_ps4' => 'PS4',
			'game_platform_ps5' => 'PS5',
			'game_platform_xbox' => 'Xbox',
			'game_platform_xbox_360' => 'Xbox 360',
			'game_platform_xbox_one' => 'Xbox One',
			'game_platform_snes' => 'SNES',
			'game_platform_nes' => 'NES',
			'game_platform_mega_drive' => 'Mega Drive',
			'game_platform_gba' => 'GBA',
			'game_platform_xbox_series_xs' => 'Xbox Series X/S',
			'game_platform_mobile' => 'Mobile',
			'game_platform_vr' => 'VR',
			'game_platform_other' => 'Outro',
			'game_hours_played_label' => 'Horas jogadas',
			_ => null,
		};
	}
}
