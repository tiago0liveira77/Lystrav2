import 'package:flutter/material.dart';

bool shouldReduceMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;

Duration animDuration(BuildContext context, Duration normal) =>
    shouldReduceMotion(context) ? Duration.zero : normal;

const kDurationFast = Duration(milliseconds: 150);
const kDurationNormal = Duration(milliseconds: 250);
const kDurationSlow = Duration(milliseconds: 350);
const kDurationCheckOff = Duration(milliseconds: 280);
const kDurationStrikethrough = Duration(milliseconds: 200);
const kDurationProgress = Duration(milliseconds: 350);
