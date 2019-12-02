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

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  Setup setup = new Setup(driver);
  setup.main();

  //  Identifiers for the welcome and provider page
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

  //  Identifiers for login forms
  final signInCoiDebug = find.text(loginProviderSignInText);
  final email = find.byValueKey(keyProviderSignInEmailTextField);
  final password = find.byValueKey(keyProviderSignInPasswordTextField);
  final signInCaps = find.text(L.getKey(L.loginSignIn).toUpperCase());
  final errorMessage = find.text(L.getKey(L.loginCheckMail));

  // Identifiers for the chat list
  final chatWelcome = find.text(L.getKey(L.chatListPlaceholder));

  group('Login preparations:', () {
    test('Show welcome screen and provider list', () async {
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

    test('Select provider', () async {
      await setup.driver.scroll(find.text(mailCom), 0, -600, Duration(milliseconds: 500));
      await selectAndTapProvider(setup.driver, find.text(coiDebug), signInCoiDebug, email, password);
      await catchScreenshot(setup.driver, 'screenshots/providerDebug.png');
    });
  });

  group('Failing logins (missing data):', () {
    test('Login without email and password', () async {
      await getAuthentication(setup.driver, email, blankSpace, password, blankSpace, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withoutEmailAndPassword.png');
    });

    test('Login without email', () async {
      await getAuthentication(setup.driver, email, blankSpace, password, fakePassword, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withoutEmail.png');
    });

    test('Login without password, with invalid email', () async {
      await getAuthentication(setup.driver, email, fakeInvalidEmail, password, blankSpace, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withoutPasswordWithInvalidEmail.png');
    });

    test('Login without password, with valid email', () async {
      await getAuthentication(setup.driver, email, fakeValidEmail, password, blankSpace, signInCaps);
      await setup.driver.waitFor(find.text(settingsIncomplete));
      await setup.driver.tap(find.text(ok));
      await catchScreenshot(setup.driver, 'screenshots/withoutPasswordValidEmail.png');
    });
  });

  group('Failing logins (wrong data):', () {
    test('Login with invalid email, with wrong password', () async {
      await getAuthentication(setup.driver, email, fakeInvalidEmail, password, fakePassword, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withInvalidEmailWithWrongPassword.png');
    });

    test('Login with invalid email, with correct password', () async {
      await getAuthentication(setup.driver, email, fakeInvalidEmail, password, realPassword, signInCaps);
      await setup.driver.waitFor(errorMessage);
      await catchScreenshot(setup.driver, 'screenshots/withInvalidEmailWithPassword.png');
    });

    test('Login with valid wrong email, with wrong password', () async {
      await getAuthentication(setup.driver, email, fakeValidEmail, password, fakePassword, signInCaps);
      await setup.driver.waitFor(find.text('Login failed'));
      await setup.driver.tap(find.text(ok));
      await catchScreenshot(setup.driver, 'screenshots/withWrongEmailWithWrongPassword.png');
    }, timeout: Timeout(Duration(seconds: 60)));

    test('Login with valid wrong email, with correct password', () async {
      await getAuthentication(setup.driver, email, fakeValidEmail, password, realPassword, signInCaps);
      await setup.driver.waitFor(find.text('Login failed'));
      await setup.driver.tap(find.text(ok));
      await catchScreenshot(setup.driver, 'screenshots/withWrongEmailWithPassword.png');
    }, timeout: Timeout(Duration(seconds: 60)));

    test('Login with correct email, with wrong password', () async {
      await getAuthentication(setup.driver, email, realEmail, password, fakePassword, signInCaps);
      await setup.driver.tap(find.text(ok));
      await catchScreenshot(setup.driver, 'screenshots/withEmailWithWrongPassword.png');
    }, timeout: Timeout(Duration(seconds: 60)));
  });

  group('Successful logins:', () {
    test('Login with correct email, with correct password', () async {
      await getAuthentication(setup.driver, email, realEmail, password, realPassword, signInCaps);
      await setup.driver.waitFor(chatWelcome);
      await catchScreenshot(setup.driver, 'screenshots/chat.png');
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

  //  Check if all providers are in the list
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
}
