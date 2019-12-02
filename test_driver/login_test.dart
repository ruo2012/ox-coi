/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

// Imports the Flutter Driver API.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/l10n/l.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  // Setup for the test.
  Setup setup = new Setup(driver);
  setup.main();

  //  SerializableFinder for the Ox coi welcome and provider page.
  final welcomeMessage = find.text(L.getKey(L.welcome));
  final welcomeDescription = find.text(L.getKey(L.loginWelcome));
  final register = find.text(L.getKey(L.register).toUpperCase());
  final signIn = find.text(L.getKey(L.loginSignIn));
  final other = find.text(L.getKey(L.providerOtherMailProvider));
  final outlook = find.text('Outlook');
  final yahoo = find.text('Yahoo');
  final mailbox = find.text('Mailbox.org');
  final blankSpace = '';
  final settingsIncomplete = 'Account settings incomplete.';
  final loginProviderSignInText = 'Sign in with Debug (mobile-qa)';

  //  SerializableFinder for Coi Debug dialog Windows.
  final signInCoiDebug = find.text(loginProviderSignInText);
  final email = find.byValueKey(keyProviderSignInEmailTextField);
  final password = find.byValueKey(keyProviderSignInPasswordTextField);
  final signInCaps = find.text(L.getKey(L.loginSignIn).toUpperCase());
  final errorMessage = find.text(L.getKey(L.loginCheckMail));
  final chatWelcome = find.text(L.getKey(L.chatListPlaceholder));

  group('Performing welcome menu and provider list', () {
    test(': Check welcome menu and provider list.', () async {
      //  Test Ox.coi welcome screen and tap on SIGN In to get the provider list, and test if all provider are contained in the list.
      await checkOxCoiWelcomeAndProviderList(
        setup.driver,
        welcomeMessage,
        welcomeDescription,
        signInCaps,
        register,
        outlook,
        yahoo,
        signIn,
        find.text(coiDebug),
        other,
        mailbox,
      );
    });
  });

  group('Choose provider before performing fake login', () {
    test(': Scroll and select the coiDebug provider.', () async {
      await setup.driver.scroll(find.text(mailCom), 0, -600, Duration(milliseconds: 500));
      await selectAndTapProvider(setup.driver, find.text(coiDebug), signInCoiDebug, email, password);
      await catchScreenshot(setup.driver, 'screenshots/CoiDebug.png');
    });
  });

  group('Performing login without EMail or password.', () {
    test(': SIGN IN without EMail and password.', () async {
      await getAuthentication(setup.driver, email, blankSpace, password, blankSpace, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withoutEmailAndPassword.png');
    });

    test(': SIGN IN without EMail but with fake password.', () async {
      await getAuthentication(setup.driver, email, blankSpace, password, fakePassword, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withoutEmail.png');
    });

    test(': SIGN IN without password but with fake invalid EMail.', () async {
      await getAuthentication(setup.driver, email, fakeInvalidEmail, password, blankSpace, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withoutPassword.png');
    });

    test(': SIGN IN without password but with fake valid EMail.', () async {
      await getAuthentication(setup.driver, email, fakeValidEmail, password, blankSpace, signInCaps);
      await setup.driver.waitFor(find.text(settingsIncomplete));
      await setup.driver.tap(find.text(ok));
      await catchScreenshot(setup.driver, 'screenshots/withoutPassword.png');
    });
  });

  group('Performing login with fake login information', () {
    test(': SIGN IN with fake invalid EMail and fake password.', () async {
      Invoker.current.heartbeat();
      await getAuthentication(setup.driver, email, fakeInvalidEmail, password, fakePassword, signInCaps);
      await setup.driver.waitFor(errorMessage);
    });

    test(': SIGN IN with fake valid EMail and fake password.', () async {
      await getAuthentication(setup.driver, email, fakeValidEmail, password, fakePassword, signInCaps);
      await setup.driver.waitFor(find.text('Login failed'));
      await setup.driver.tap(find.text(ok));
      await catchScreenshot(setup.driver, 'screenshots/withoutPassword.png');
    });

    test(': SIGN IN with fake invalid EMail and real password.', () async {
      Invoker.current.heartbeat();
      await getAuthentication(setup.driver, email, fakeInvalidEmail, password, realPassword, signInCaps);
      await setup.driver.waitFor(errorMessage);
    });

    test(': SIGN IN with fake valid EMail and real password.', () async {
      await getAuthentication(setup.driver, email, fakeValidEmail, password, realPassword, signInCaps);
      await setup.driver.waitFor(find.text('Login failed'));
      await setup.driver.tap(find.text(ok));
      await catchScreenshot(setup.driver, 'screenshots/withoutPassword.png');
    });

    test(': SIGN IN with real EMail and fake password.', () async {
      Invoker.current.heartbeat();
      await getAuthentication(setup.driver, email, realEmail, password, fakePassword, signInCaps);
      await setup.driver.tap(find.text(ok));
    }, timeout: Timeout(Duration(seconds: 60)));
  });

  group('Performing the login with real authentication informations', () {
    test(': Login test: SIGN IN with real EMail and real password.', () async {
      await getAuthentication(setup.driver, email, realEmail, password, realPassword, signInCaps);
      await catchScreenshot(setup.driver, 'screenshots/entered.png');
      Invoker.current.heartbeat();
      print('SIGN IN ist done. Wait for chat.');
      await setup.driver.waitFor(chatWelcome);
      Invoker.current.heartbeat();
      await catchScreenshot(setup.driver, 'screenshots/chat.png');
      print('Get chat.');
    });
  });
}

Future checkOxCoiWelcomeAndProviderList(
  FlutterDriver driver,
  SerializableFinder welcomeMessage,
  SerializableFinder welcomeDescription,
  SerializableFinder signInCaps,
  SerializableFinder register,
  SerializableFinder outlook,
  SerializableFinder yahoo,
  SerializableFinder signIn,
  SerializableFinder coiDebug,
  SerializableFinder other,
  SerializableFinder mailbox,
) async {
  await driver.waitFor(signInCaps);
  await driver.waitFor(register);
  await driver.tap(signInCaps);

  //  Check if all providers are found in the list.
  await driver.waitFor(outlook);
  await driver.waitFor(yahoo);
  await driver.waitFor(signIn);
  await driver.waitFor(coiDebug);
  await driver.waitFor(other);
  await driver.waitFor(mailbox);
}

Future selectAndTapProvider(
  FlutterDriver driver,
  SerializableFinder coiDebug,
  SerializableFinder signInCoiDebug,
  SerializableFinder email,
  SerializableFinder password,
) async {
  await driver.tap(coiDebug);
  await driver.waitFor(signInCoiDebug);
  await driver.waitFor(email);
  await driver.waitFor(password);
}

Future getAuthentication(
  FlutterDriver driver,
  SerializableFinder email,
  String fakeEmail,
  SerializableFinder password,
  String realPassword,
  SerializableFinder signInCaps,
) async {
  await driver.tap(email);
  await driver.enterText(fakeEmail);
  await driver.waitFor(email);
  await driver.tap(password);
  await driver.enterText(realPassword);
  await driver.tap(signInCaps);
  Invoker.current.heartbeat();
}
