import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_standard_header.dart';
import '../../../app/providers/auth_provider.dart';
import '../../auth/domain/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Farmer role-specific state
  String _farmName = 'Green Field Organic Farm';
  String _farmLocation = 'Madurai North District, Tamil Nadu';
  String _landArea = '12.5 Acres';
  String _primaryCrops = 'Organic Tomatoes, Palak, Carrots';
  String _fssaiNo = 'FSSAI-124210098210';
  String _payoutUpi = 'greenfield@okaxis';

  // Consumer role-specific state
  String _deliveryAddress = '12 Harvest Lane, Farm District, Madurai - 625001';
  String _landmark = 'Opposite Kaveri Water Gate';
  String _altPhone = '+91 94431 88210';
  String _prefTimeSlot = 'Morning Slot (07:00 AM - 10:00 AM)';

  // Delivery Partner role-specific state
  String _vehicleType = 'TVS King Electric 3-Wheeler';
  String _vehicleReg = 'TN 58 AX 8821';
  String _dlNumber = 'TN58 20210088210';
  String _serviceZone = 'Madurai Metro Zone (North & East)';
  String _emergencyContact = '+91 98421 99110';

  // Admin role-specific state
  String _adminDesignation = 'Chief Operations Administrator';
  String _clearanceLevel = 'Level-5 Master Control';
  String _operationalDivision = 'Tamil Nadu South Division';

  void _showEditBasicProfileModal(BuildContext context, User? user) {
    final nameCtrl = TextEditingController(text: user?.name ?? 'Marketplace User');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '+91 9876543210');
    final emailCtrl = TextEditingController(text: user?.email ?? 'user@vayal2veedu.com');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                onPressed: () {
                  ref.read(authProvider.notifier).updateUserProfile(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account details updated successfully!')),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Save Profile Updates'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditRoleDetailsModal(BuildContext context, UserRole role) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        if (role == UserRole.FARMER) {
          final farmCtrl = TextEditingController(text: _farmName);
          final locCtrl = TextEditingController(text: _farmLocation);
          final areaCtrl = TextEditingController(text: _landArea);
          final cropsCtrl = TextEditingController(text: _primaryCrops);
          final fssaiCtrl = TextEditingController(text: _fssaiNo);
          final upiCtrl = TextEditingController(text: _payoutUpi);

          return Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Farm & Produce Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(controller: farmCtrl, decoration: const InputDecoration(labelText: 'Farm Name', prefixIcon: Icon(Icons.storefront))),
                  const SizedBox(height: 12),
                  TextFormField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Farm District / Location', prefixIcon: Icon(Icons.location_on_outlined))),
                  const SizedBox(height: 12),
                  TextFormField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'Total Land Area', prefixIcon: Icon(Icons.square_foot))),
                  const SizedBox(height: 12),
                  TextFormField(controller: cropsCtrl, decoration: const InputDecoration(labelText: 'Primary Crops Grown', prefixIcon: Icon(Icons.eco_outlined))),
                  const SizedBox(height: 12),
                  TextFormField(controller: fssaiCtrl, decoration: const InputDecoration(labelText: 'FSSAI License / Organic Certification', prefixIcon: Icon(Icons.verified_outlined))),
                  const SizedBox(height: 12),
                  TextFormField(controller: upiCtrl, decoration: const InputDecoration(labelText: 'Payout UPI ID', prefixIcon: Icon(Icons.payments_outlined))),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    onPressed: () {
                      setState(() {
                        _farmName = farmCtrl.text.trim();
                        _farmLocation = locCtrl.text.trim();
                        _landArea = areaCtrl.text.trim();
                        _primaryCrops = cropsCtrl.text.trim();
                        _fssaiNo = fssaiCtrl.text.trim();
                        _payoutUpi = upiCtrl.text.trim();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farm profile updated!')));
                    },
                    child: const Text('Save Farm Details'),
                  ),
                ],
              ),
            ),
          );
        } else if (role == UserRole.CONSUMER) {
          final addrCtrl = TextEditingController(text: _deliveryAddress);
          final landmarkCtrl = TextEditingController(text: _landmark);
          final altPhoneCtrl = TextEditingController(text: _altPhone);

          return Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Delivery Address & Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(controller: addrCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Primary Delivery Address', prefixIcon: Icon(Icons.home_outlined))),
                const SizedBox(height: 12),
                TextFormField(controller: landmarkCtrl, decoration: const InputDecoration(labelText: 'Landmark', prefixIcon: Icon(Icons.place_outlined))),
                const SizedBox(height: 12),
                TextFormField(controller: altPhoneCtrl, decoration: const InputDecoration(labelText: 'Alternate Contact Phone', prefixIcon: Icon(Icons.phone_android_outlined))),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  onPressed: () {
                    setState(() {
                      _deliveryAddress = addrCtrl.text.trim();
                      _landmark = landmarkCtrl.text.trim();
                      _altPhone = altPhoneCtrl.text.trim();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery preferences saved!')));
                  },
                  child: const Text('Save Preferences'),
                ),
              ],
            ),
          );
        } else if (role == UserRole.DELIVERY_PARTNER) {
          final vehicleCtrl = TextEditingController(text: _vehicleType);
          final regCtrl = TextEditingController(text: _vehicleReg);
          final dlCtrl = TextEditingController(text: _dlNumber);
          final zoneCtrl = TextEditingController(text: _serviceZone);

          return Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Vehicle & Rider Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(controller: vehicleCtrl, decoration: const InputDecoration(labelText: 'Vehicle Type', prefixIcon: Icon(Icons.two_wheeler))),
                  const SizedBox(height: 12),
                  TextFormField(controller: regCtrl, decoration: const InputDecoration(labelText: 'Vehicle Registration No.', prefixIcon: Icon(Icons.badge_outlined))),
                  const SizedBox(height: 12),
                  TextFormField(controller: dlCtrl, decoration: const InputDecoration(labelText: 'Driving License No.', prefixIcon: Icon(Icons.card_membership))),
                  const SizedBox(height: 12),
                  TextFormField(controller: zoneCtrl, decoration: const InputDecoration(labelText: 'Service Zone', prefixIcon: Icon(Icons.map_outlined))),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    onPressed: () {
                      setState(() {
                        _vehicleType = vehicleCtrl.text.trim();
                        _vehicleReg = regCtrl.text.trim();
                        _dlNumber = dlCtrl.text.trim();
                        _serviceZone = zoneCtrl.text.trim();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rider profile updated!')));
                    },
                    child: const Text('Save Rider Profile'),
                  ),
                ],
              ),
            ),
          );
        } else {
          final desigCtrl = TextEditingController(text: _adminDesignation);
          final divCtrl = TextEditingController(text: _operationalDivision);

          return Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Admin Designation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(controller: desigCtrl, decoration: const InputDecoration(labelText: 'Admin Designation', prefixIcon: Icon(Icons.work_outline))),
                const SizedBox(height: 12),
                TextFormField(controller: divCtrl, decoration: const InputDecoration(labelText: 'Operational Division', prefixIcon: Icon(Icons.domain))),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  onPressed: () {
                    setState(() {
                      _adminDesignation = desigCtrl.text.trim();
                      _operationalDivision = divCtrl.text.trim();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin designation saved!')));
                  },
                  child: const Text('Save Admin Profile'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role ?? UserRole.CONSUMER;

    return Scaffold(
      appBar: const AppStandardHeader(
        title: 'Vayal 2 Veedu',
        subtitle: 'My Account & Profile',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryGreen, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/app_logo_icon.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Marketplace User',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'user@vayal2veedu.com',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              userRoleToString(role).replaceAll('_', ' '),
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Basic Account Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_pin_outlined, color: AppColors.primaryGreen, size: 20),
                            SizedBox(width: 8),
                            Text('Personal Contact Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _showEditBasicProfileModal(context, user),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                    const Divider(),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
                      title: const Text('Registered Phone Number'),
                      subtitle: Text(user?.phone ?? '+91 9876543210', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.email_outlined, color: AppColors.primaryGreen),
                      title: const Text('Email Address'),
                      subtitle: Text(user?.email ?? 'user@vayal2veedu.com', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Role-Specific Profile Extension Card
            if (role == UserRole.FARMER)
              _buildRoleProfileCard(
                title: 'Farmer & Farm Details',
                icon: Icons.agriculture,
                color: AppColors.primaryGreen,
                onEdit: () => _showEditRoleDetailsModal(context, role),
                items: [
                  MapEntry('Farm Name', _farmName),
                  MapEntry('Location / District', _farmLocation),
                  MapEntry('Total Land Area', _landArea),
                  MapEntry('Primary Produce', _primaryCrops),
                  MapEntry('FSSAI License No.', _fssaiNo),
                  MapEntry('Payout UPI Account', _payoutUpi),
                ],
              )
            else if (role == UserRole.CONSUMER)
              _buildRoleProfileCard(
                title: 'Consumer Delivery Profile',
                icon: Icons.home_work_outlined,
                color: AppColors.secondaryOrange,
                onEdit: () => _showEditRoleDetailsModal(context, role),
                items: [
                  MapEntry('Primary Delivery Address', _deliveryAddress),
                  MapEntry('Landmark', _landmark),
                  MapEntry('Alternate Phone', _altPhone),
                  MapEntry('Preferred Delivery Slot', _prefTimeSlot),
                ],
              )
            else if (role == UserRole.DELIVERY_PARTNER)
              _buildRoleProfileCard(
                title: 'Delivery Rider & Vehicle Profile',
                icon: Icons.two_wheeler_outlined,
                color: AppColors.info,
                onEdit: () => _showEditRoleDetailsModal(context, role),
                items: [
                  MapEntry('Vehicle Type', _vehicleType),
                  MapEntry('Vehicle Registration', _vehicleReg),
                  MapEntry('Driving License No.', _dlNumber),
                  MapEntry('Operating City Zone', _serviceZone),
                  MapEntry('Emergency Contact', _emergencyContact),
                ],
              )
            else
              _buildRoleProfileCard(
                title: 'Platform Administrator Profile',
                icon: Icons.shield_outlined,
                color: Colors.purple,
                onEdit: () => _showEditRoleDetailsModal(context, role),
                items: [
                  MapEntry('Admin Designation', _adminDesignation),
                  MapEntry('Clearance Level', _clearanceLevel),
                  MapEntry('Admin Email', 'tharunpranavt@vayal2veedu.com'),
                  MapEntry('Operational Division', _operationalDivision),
                  MapEntry('Security Audit Status', 'Verified Active & Encrypted ✓'),
                ],
              ),

            const SizedBox(height: 28),

            // Sign Out Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                foregroundColor: AppColors.error,
                elevation: 0,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/role-selection');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out of Vayal 2 Veedu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleProfileCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
    required List<MapEntry<String, String>> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(item.key, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(item.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
