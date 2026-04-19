import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Connect With Us Screen
/// Simple screen to redirect users to institute's social media handles
class ConnectWithUsScreen extends StatelessWidget {
  const ConnectWithUsScreen({super.key});

  /// Launch external URL
  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Connect With Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header message
            const GlassCard(
              child: Row(
                children: [
                  Icon(
                    Icons.connect_without_contact_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stay Connected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Follow us on social media for updates, news, and announcements',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Social Media Cards
            _SocialMediaCard(
              icon: Icons.camera_alt_rounded,
              title: 'Follow us on Instagram',
              subtitle: 'Get daily updates and behind-the-scenes content',
              color: const Color(0xFFE4405F),
              onTap: () => _launchURL(context, 'https://www.instagram.com/indrajeetacademy?igsh=dzB5dzk4OXltYnlu'),
            ),
            const SizedBox(height: 12),

            _SocialMediaCard(
              icon: Icons.play_circle_rounded,
              title: 'Subscribe on YouTube',
              subtitle: 'Watch educational videos and tutorials',
              color: const Color(0xFFFF0000),
              onTap: () => _launchURL(context, 'https://www.youtube.com/@IndrajeetAcademyThane'),
            ),
            const SizedBox(height: 12),

            _SocialMediaCard(
              icon: Icons.chat_rounded,
              title: 'Chat on WhatsApp',
              subtitle: 'Quick support and instant communication',
              color: const Color(0xFF25D366),
              onTap: () => _launchURL(context, 'https://wa.me/919876543210'),
            ),
            const SizedBox(height: 12),

            _SocialMediaCard(
              icon: Icons.language_rounded,
              title: 'Visit Our Website',
              subtitle: 'Explore courses, resources, and more',
              color: AppColors.primary,
              onTap: () => _launchURL(context, 'https://vidyasarthi.edu.in'),
            ),
            const SizedBox(height: 12),

            _SocialMediaCard(
              icon: Icons.email_rounded,
              title: 'Email Us',
              subtitle: 'Send us your queries and feedback',
              color: AppColors.info,
              onTap: () => _launchURL(context, 'mailto:contact@vidyasarthi.edu.in'),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// Social Media Card Widget
class _SocialMediaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SocialMediaCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
