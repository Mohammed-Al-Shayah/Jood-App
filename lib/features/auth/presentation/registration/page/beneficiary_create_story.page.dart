import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';

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
        title: Text(AppStrings.createStory),
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
                  child: Text(AppStrings.next),
                ),
                SizedBox(width: 12.w),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(AppStrings.previous),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text(
              AppStrings.stepNumber(1),
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
            ),
            content: Text(
              AppStrings.storyStep1Description,
              style: AppTextStyles.cardMeta,
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text(
              AppStrings.stepNumber(2),
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
            ),
            content: Text(
              AppStrings.storyStep2Description,
              style: AppTextStyles.cardMeta,
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text(
              AppStrings.stepNumber(3),
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
            ),
            content: Text(
              AppStrings.storyStep3Description,
              style: AppTextStyles.cardMeta,
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
