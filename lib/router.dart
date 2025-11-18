import 'package:go_router/go_router.dart';
import 'core/controllers/auth_controller.dart';

// === AUTH ===
import 'modules/auth/login.dart';
import 'modules/auth/register.dart';
import 'modules/auth/forgot_password.dart';

// === SHARED ===
import 'modules/shared/pages/berita/berita.dart';
import 'modules/shared/pages/berita/berita_detail.dart';
import 'modules/shared/pages/berita/berita_rt.dart';
import 'modules/shared/pages/berita/berita_rt_detail.dart';
import 'modules/shared/pages/akun/akun.dart';
import 'modules/shared/pages/akun/akun_profil.dart';
import 'modules/shared/pages/akun/akun_profil_form.dart';
import 'modules/shared/pages/akun/akun_change_password.dart';

// === PERANGKAT DESA ===
import 'modules/perangkat_desa/pd_main.dart';
import 'modules/perangkat_desa/pages/pd_beranda.dart';
import 'modules/perangkat_desa/pages/pd_data.dart';
import 'modules/perangkat_desa/pages/data/users/pd_users.dart';
import 'modules/perangkat_desa/pages/data/users/pd_users_form.dart';
import 'modules/perangkat_desa/pages/data/areas/pd_areas.dart';
import 'modules/perangkat_desa/pages/data/areas/pd_areas_form.dart';
import 'modules/perangkat_desa/pages/data/services/pd_services.dart';
import 'modules/perangkat_desa/pages/data/services/pd_services_form.dart';
import 'modules/perangkat_desa/pages/data/news/pd_news.dart';
import 'modules/perangkat_desa/pages/data/news/pd_news_form.dart';
import 'modules/perangkat_desa/pages/data/requests/pd_requests.dart';
import 'modules/perangkat_desa/pages/data/requests/pd_requests_detail.dart';

// === WARGA ===
import 'modules/warga/wg_main.dart';
import 'modules/warga/pages/wg_beranda.dart';
import 'modules/warga/pages/wg_pengajuan.dart';
import 'modules/warga/pages/wg_pengajuan_form.dart';
import 'modules/warga/pages/wg_pengajuan_success.dart';
import 'modules/warga/pages/wg_pengajuan_detail.dart';

// === RT ===
import 'modules/rt/rt_main.dart';
import 'modules/rt/pages/beranda_rt.dart';


final _authController = AuthController();

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth/login',
  redirect: (context, state) => _authController.redirectLogic(state.uri.path),
  routes: [
    // === AUTH ===
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordPage()),

    // === PERANGKAT DESA ===
    ShellRoute(
      builder: (context, state, child) => PerangkatDesaMain(child: child),
      routes: [
        GoRoute(path: '/pd/beranda', builder: (_, __) => DesaBerandaPage()),
        GoRoute(path: '/pd/data', builder: (_, __) => const DesaDataPage()),
        GoRoute(path: '/pd/data/users', builder: (_, __) => const DesaDataUsersPage()),
        GoRoute(path: '/pd/data/users/add', builder: (_, __) => const DesaDataUsersFormPage()),
        GoRoute(path: '/pd/data/users/edit', builder: (context, state) => DesaDataUsersFormPage(id: state.uri.queryParameters['id'])),
        GoRoute(path: '/pd/data/areas', builder: (_, __) => const DesaDataAreasPage()),
        GoRoute(path: '/pd/data/areas/add', builder: (_, __) => const DesaDataAreasFormPage()),
        GoRoute(path: '/pd/data/areas/edit', builder: (context, state) => DesaDataAreasFormPage(id: state.uri.queryParameters['id'])),
        GoRoute(path: '/pd/data/services', builder: (_, __) => const DesaDataServicesPage()),
        GoRoute(path: '/pd/data/services/add', builder: (_, __) => const DesaDataServicesFormPage()),
        GoRoute(path: '/pd/data/services/edit', builder: (context, state) => DesaDataServicesFormPage(id: state.uri.queryParameters['id'])),
        GoRoute(path: '/pd/data/news', builder: (_, __) => const DesaDataNewsPage()),
        GoRoute(path: '/pd/data/news/add', builder: (_, __) => const DesaDataNewsFormPage()),
        GoRoute(path: '/pd/data/news/edit', builder: (context, state) => DesaDataNewsFormPage(id: state.uri.queryParameters['id'])),
        GoRoute(path: '/pd/data/requests', builder: (_, __) => const DesaDataRequestsPage()),
        GoRoute(
          path: '/pd/data/requests/detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return DesaDataRequestsDetailPage(id: extra['id']);
          },
        ),

        GoRoute(path: '/pd/berita', builder: (_, __) => BeritaPage()),
        GoRoute(
          path: '/pd/berita/detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final newsId = extra['newsId'] as String;
            return BeritaDetailPage(newsId: newsId);
          },
        ),

        GoRoute(path: '/pd/akun', builder: (_, __) => AkunPage(routePrefix: 'pd')),
        GoRoute(path: '/pd/akun/profil', builder: (_, __) => const AkunProfilPage(routePrefix: 'pd')),
        GoRoute(path: '/pd/akun/profil/form', builder: (_, __) => const AkunProfilFormPage(routePrefix: 'pd')),
        GoRoute(path: '/pd/akun/password', builder: (_, __) => const AkunChangePasswordPage(routePrefix: 'pd')),
      ],
    ),

    // === WARGA ===
    ShellRoute(
      builder: (context, state, child) => WargaMain(child: child),
      routes: [
        GoRoute(path: '/wg/beranda', builder: (_, __) => WargaBerandaPage()),
        GoRoute(path: '/wg/pengajuan', builder: (_, __) => WargaPengajuanPage()),
        GoRoute(path: '/wg/pengajuan/add', builder: (_, __) => const WargaPengajuanFormPage()),
        GoRoute(path: '/wg/pengajuan/success', builder: (_, __) => const WargaPengajuanSuccessPage()),
        GoRoute(
          path: '/wg/pengajuan/detail',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return WargaPengajuanDetailPage(data: data);
          },
        ),
        GoRoute(path: '/wg/berita', builder: (_, __) => BeritaPage()),
        GoRoute(
          path: '/wg/berita/detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final newsId = extra['newsId'] as String;
            return BeritaDetailPage(newsId: newsId);
          },
        ),

        GoRoute(path: '/wg/akun', builder: (_, __) => AkunPage(routePrefix: 'wg')),
        GoRoute(path: '/wg/akun/profil', builder: (_, __) => const AkunProfilPage(routePrefix: 'wg')),
        GoRoute(path: '/wg/akun/profil/form', builder: (_, __) => const AkunProfilFormPage(routePrefix: 'wg')),
        GoRoute(path: '/wg/akun/password', builder: (_, __) => const AkunChangePasswordPage(routePrefix: 'wg')),
      ],
    ),

    // === RT ===
    ShellRoute(
      builder: (context, state, child) => RTMain(child: child),
      routes: [
        GoRoute(path: '/rt/beranda', builder: (_, __) => const BerandaRT()),
        GoRoute(path: '/rt/berita', builder: (_, __) => BeritaRTPage()),
        GoRoute(
          path: '/rt/berita/detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final newsId = extra['newsId'] as String;
            return BeritaRTDetailPage(newsId: newsId);
          },
        ),
      ],
    ),
  ],
);
