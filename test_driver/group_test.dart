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

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ox_coi/src/utils/keyMapping.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

import 'setup/global_consts.dart';
import 'setup/helper_methods.dart';
import 'setup/main_test_setup.dart';

void main() {
  //  Define the driver.
  FlutterDriver driver;
  Setup setup = new Setup(driver);
  setup.main();

  final testNameGroup = "TestGroup";
  final newNameTestGroup = "NewNameTestGroup";
  final keyMoreButton11 = "keyMoreButton_11";
  final keyMoreButton10 = "keyMoreButton_10";
  final popupItemInfo = "Info";
  final popupItemRemove = "Remove from group";
  final popupItemSendMessage = "Send message";
  final searchNew = "new";
  final groupParticipants = "3 participants";

  group('Test preparation:', () {
    test('Get login.', () async {
      //  Check real authentication and get chat.
      await getAuthentication(
        setup.driver,
        signInFinder,
        coiDebugProviderFinder,
        providerEmailFinder,
        realEmail,
        providerPasswordFinder,
        realPassword,
      );
    });
  });

  group('Group preparation:', () {
    test('Add contacts.', () async {
      await navigateTo(setup.driver, contacts);

      await setup.driver.tap(cancelFinder);
      // Add tree new contacts in the contact list.
      await addNewContact(
        setup.driver,
        personAddFinder,
        keyContactChangeNameFinder,
        newTestName01,
        keyContactChangeEmailFinder,
        newTestContact04,
        keyContactChangeCheckFinder,
      );
      await addNewContact(
        setup.driver,
        personAddFinder,
        keyContactChangeNameFinder,
        newTestName02,
        keyContactChangeEmailFinder,
        newTestContact02,
        keyContactChangeCheckFinder,
      );
      await addNewContact(
        setup.driver,
        personAddFinder,
        keyContactChangeNameFinder,
        newMe,
        keyContactChangeEmailFinder,
        newTestContact03,
        keyContactChangeCheckFinder,
      );
      await catchScreenshot(setup.driver, 'screenshots/contactList.png');
    });

    test('Create group.', () async {
      navigateTo(setup.driver, chat);
      await setup.driver.tap(createChatFinder);
      //  Tap Create group iconButton.
      await setup.driver.tap(find.byValueKey(keyChatCreateGroupAddIcon));
      //  Select contact to create group.
      await setup.driver.tap(find.text(newTestName01));
      await setup.driver.tap(find.text(newTestName02));
      //  Validate an create group.
      await setup.driver.tap(find.byValueKey(keyChatCreateGroupParticipantsSummitIconButton));
      //  Check if the group has been really created, and add group's name.
      await setup.driver.waitFor(find.text(newTestName01));
      await setup.driver.waitFor(find.text(newTestName02));
      //  Edit group name.
      await setup.driver.tap(find.byValueKey(keyChatCreateGroupSettingsGroupNameField));
      await setup.driver.enterText(testNameGroup);
      await setup.driver.tap(find.byValueKey(keyChatCreateGroupSettingCheckIconButton));
      await catchScreenshot(setup.driver, 'screenshots/groupNameAfterEdited.png');
      await setup.driver.tap(pageBack);
    });
  });

  group('Test group chat functionality:', () {
    test('Change edited group name', () async {
      await setup.driver.tap(find.text(testNameGroup));
      await setup.driver.tap(find.text(testNameGroup));
      await setup.driver.tap(find.byValueKey(keyChatProfileGroupEditIcon));
      await setup.driver.tap(find.byValueKey(keyEditNameValidatableTextFormField));
      await setup.driver.enterText(newNameTestGroup);
      await setup.driver.tap(find.byValueKey(keyEditNameCheckIcon));
      await setup.driver.waitFor(find.text(newNameTestGroup));
      await setup.driver.tap(pageBack);
      await setup.driver.tap(pageBack);
      await catchScreenshot(setup.driver, 'screenshots/newNameTestGroup.png');
    });

    test('Create group chat, type something and get it.', () async {
      await chatTest(
        setup.driver,
        newNameTestGroup,
        typeSomethingComposePlaceholderFinder,
        helloWorld,
      );
      await setup.driver.tap(pageBack);
    });

    test('Add new Participants in the group.', () async {
      await setup.driver.tap(find.text(newNameTestGroup));
      await setup.driver.tap(find.byValueKey(keyChatNameText));
      await setup.driver.tap(find.byValueKey(keyChatProfileGroupAddParticipant));
      await setup.driver.tap(find.byValueKey(keyChatAddGroupParticipantsSearchIcon));
      await catchScreenshot(setup.driver, 'screenshots/newContactAdded.png');
      await setup.driver.enterText(searchNew);
      await setup.driver.tap(find.text(newMe));
      await setup.driver.tap(find.byValueKey(keySearchReturnIconButton));
      await setup.driver.tap(find.byValueKey(keyChatAddGroupParticipantsCheckIcon));
      await setup.driver.waitFor(find.text(groupParticipants));
      await catchScreenshot(setup.driver, 'screenshots/newContactAdded2.png');

    });

    test('Check popupMenu.', () async {
      //  Test info menu
      await setup.driver.tap(find.byValueKey(keyMoreButton11));
      await setup.driver.tap(find.text(popupItemInfo));
      await setup.driver.tap(pageBack);
      //  Test remove menu.
      await setup.driver.tap(find.byValueKey(keyMoreButton11));
      await setup.driver.tap(find.text(popupItemRemove));
      await setup.driver.waitFor(find.text(newTestName01));
      //  Test send menu.
      await setup.driver.tap(find.byValueKey(keyMoreButton10));
      await setup.driver.tap(find.text(popupItemSendMessage));
      await writeChatFromChat(setup.driver, helloWorld);
      await setup.driver.tap(pageBack);
    });

    test('Leave group.', () async {
      await setup.driver.tap(find.text(newNameTestGroup));
      await setup.driver.tap(find.byValueKey(keyChatNameText));
      await setup.driver.tap(find.byValueKey(keyChatProfileGroupDelete));
      await setup.driver.tap(find.byValueKey(keyConfirmationDialogPositiveButton));
      await setup.driver.waitForAbsent(find.text(newNameTestGroup));
      await catchScreenshot(setup.driver, 'screenshots/leaveGroup.png');

    });
  });
}
