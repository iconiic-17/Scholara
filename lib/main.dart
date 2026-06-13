import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Screens/SplashScreen.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'package:grantgo/cubit/CV/cubit/cv_cubit.dart';
import 'package:grantgo/cubit/Motivation/cubit/motivation_cubit.dart';
import 'package:grantgo/cubit/interview/cubit/interview_cubit.dart';
import 'package:grantgo/cubit/login/login_cubit.dart';
import 'package:grantgo/cubit/profile/cubit/profile_cubit.dart';
import 'package:grantgo/cubit/scholarship/cubit/saved_scholarship_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => SavedScholarshipsCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (_) => CvCubit(appDio)),
        BlocProvider(create: (_) => MotivationCubit(appDio)),
        BlocProvider(create: (_) => InterviewCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splashscreen(),
      ),
    ),
  );
}
