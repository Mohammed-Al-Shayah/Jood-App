import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
class BeneficiaryCreateStoryPage extends StatefulWidget {
  const BeneficiaryCreateStoryPage({super.key});

  @override
  State<BeneficiaryCreateStoryPage> createState() =>
      _BeneficiaryCreateStoryPageState();
}

class _BeneficiaryCreateStoryPageState
    extends State<BeneficiaryCreateStoryPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Story'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Next'),
                ),
                SizedBox(width: 12.w),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text(
              'Step 1',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
            ),
            content: Text(
              'Basic information about your story.',
              style: AppTextStyles.cardMeta,
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text(
              'Step 2',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
            ),
            content: Text(
              'Details and background.',
              style: AppTextStyles.cardMeta,
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text(
              'Step 3',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
            ),
            content: Text(
              'Review and submit.',
              style: AppTextStyles.cardMeta,
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
