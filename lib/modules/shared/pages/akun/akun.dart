import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/controllers/auth_controller.dart';
import '../../../../../core/controllers/user_controller.dart';

class AkunPage extends StatelessWidget {
  final String routePrefix;
  final _authController = AuthController();

  AkunPage({super.key, required this.routePrefix});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 125,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bg_top.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 35,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              'Profil Pengguna',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF00194A),
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            border: Border.all(color: const Color(0xFF4E82EA)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: Color(0xFF4E82EA)),
                            ),
                            title: FutureBuilder<String>(
                              future: UserController().getUsernameById(AuthController().currentUser!.uid),
                              builder: (context, snapshot) {
                                final name = snapshot.data ?? 'User';
                                return Text(
                                  name, // nama di atas
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF00194A),
                                  ),
                                );
                              },
                            ),
                            subtitle: Text(
                              _authController.currentUserRole,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  sectionTitle('Akun'),
                  akunCard(context),
                  const SizedBox(height: 16),
                  sectionTitle('Lainnya'),
                  lainnyaCard(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _authController.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil logout')),
                  );
                  context.push('/auth/login');
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCA2424),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00194A),
          ),
        ),
      ),
    );
  }

  Widget akunCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF245BCA)),
              title: Text(
                'Profil Saya',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00194A),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                context.push(
                  '/$routePrefix/akun/profil',
                  extra: {'from': '/$routePrefix/akun'},
                );
              },
            ),
            const Divider(height: 1, color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFF245BCA)),
              title: Text(
                'Ubah Password',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00194A),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                context.push(
                  '/$routePrefix/akun/password',
                  extra: {'from': '/$routePrefix/akun'},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget lainnyaCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.location_city_rounded, color: Color(0xFF245BCA)),
              title: Text(
                'Tentang Desa',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00194A),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/pd/akun/desa'),
            ),
            const Divider(height: 1, color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.flutter_dash_rounded, color: Color(0xFF245BCA)),
              title: Text(
                'Tentang Aplikasi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00194A),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/pd/akun/aplikasi'),
            ),
            const Divider(height: 1, color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.book_rounded, color: Color(0xFF245BCA)),
              title: Text(
                'Panduan Aplikasi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00194A),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/pd/akun/panduan'),
            ),
            const Divider(height: 1, color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.mail_outline_rounded, color: Color(0xFF245BCA)),
              title: Text(
                'Pengaduan Bug & Saran',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF00194A),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/pd/akun/pengaduan'),
            ),
          ],
        ),
      ),
    );
  }
}