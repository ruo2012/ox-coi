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

import 'dart:io';

import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ox_coi/src/adaptiveWidgets/adaptive_icon.dart';
import 'package:ox_coi/src/message/message_attachment_bloc.dart';
import 'package:ox_coi/src/message/message_attachment_event_state.dart';
import 'package:ox_coi/src/message/message_item_bloc.dart';
import 'package:ox_coi/src/ui/color.dart';
import 'package:ox_coi/src/ui/dimensions.dart';
import 'package:ox_coi/src/utils/conversion.dart';
import 'package:ox_coi/src/utils/date.dart';
import 'package:ox_coi/src/utils/video.dart';
import 'package:path/path.dart' as path;
import 'package:transparent_image/transparent_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'message_item_event_state.dart';

class MessageData extends InheritedWidget {
  final Color backgroundColor;
  final Color textColor;
  final AdaptiveIcon icon;
  final BorderRadius borderRadius;
  final MessageStateData messageStateData;
  final Color secondaryTextColor;
  final bool useInformationText;

  MessageData({
    Key key,
    @required this.backgroundColor,
    @required this.textColor,
    @required this.borderRadius,
    @required this.messageStateData,
    this.icon,
    this.secondaryTextColor,
    this.useInformationText = false,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static MessageData of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MessageData) as MessageData;
  }
}

class MessageMaterial extends StatelessWidget {
  final Widget child;
  final double elevation;

  const MessageMaterial({Key key, @required this.child, this.elevation = messagesElevation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: MessageData.of(context).borderRadius,
      color: MessageData.of(context).backgroundColor,
      textStyle: TextStyle(color: MessageData.of(context).textColor),
      child: child,
    );
  }
}

class MessageText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getNamePaddingForGroups(context),
      child: Text(
        _getText(context),
        style: Theme.of(context).textTheme.subhead.apply(color: MessageData.of(context).textColor),
      ),
    );
  }
}

String _getText(BuildContext context) {
  return MessageData.of(context).useInformationText ? _getMessageStateData(context).informationText : _getMessageStateData(context).text;
}

MessageStateData _getMessageStateData(BuildContext context) => MessageData.of(context).messageStateData;

class MessageStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AdaptiveIcon icon = MessageData.of(context).icon;
    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: iconTextPadding),
              child: icon,
            ),
            Flexible(
              child: Text(
                _getText(context),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding),
        child: Text(
          _getMessageStateData(context).text,
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}

class MessageAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isImage(context)) {
      return MessagePartImageVideoAttachment();
    } else if (isAudio(context)) {
      return MessagePartAudioAttachment();
    } else if (isVideo(context)) {
      return MessagePartImageVideoAttachment(
        isVideo: true,
      );
    } else {
      return MessagePartGenericAttachment();
    }
  }
}

bool isImage(BuildContext context) {
  final attachment = _getMessageStateData(context).attachmentStateData;
  return attachment != null && attachment.type == ChatMsg.typeImage;
}

bool isAudio(BuildContext context) {
  final attachment = _getMessageStateData(context).attachmentStateData;
  return attachment != null && attachment.type == ChatMsg.typeAudio || attachment.type == ChatMsg.typeVoice;
}

bool isVideo(BuildContext context) {
  final attachment = _getMessageStateData(context).attachmentStateData;
  return attachment != null && attachment.type == ChatMsg.typeVideo;
}

class MessagePartAudioAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: getNamePaddingForGroups(context),
        child: Image.asset(
          "assets/images/img_audio_waves.png",
          width: audioFileImageWidth,
        ));
  }
}

class MessagePartImageVideoAttachment extends StatefulWidget {
  final bool isVideo;

  MessagePartImageVideoAttachment({this.isVideo = false});

  @override
  _MessagePartImageVideoAttachmentState createState() => _MessagePartImageVideoAttachmentState();
}

class _MessagePartImageVideoAttachmentState extends State<MessagePartImageVideoAttachment> {
  ImageProvider imageProvider;
  String thumbnailPath = "";
  String durationString = "";

  // ignore: close_sinks
  MessageAttachmentBloc _messageAttachmentBloc = MessageAttachmentBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.isVideo) {
      File file = File(_getMessageStateData(context).attachmentStateData.path);
      imageProvider = FileImage(file);
    } else {
      imageProvider = MemoryImage(kTransparentImage);
      _messageAttachmentBloc.add(LoadThumbnailAndDuration(
          path: _getMessageStateData(context).attachmentStateData.path, duration: _getMessageStateData(context).attachmentStateData.duration));
    }
    precacheImage(imageProvider, context, onError: (error, stacktrace) {
      setState(() {
        imageProvider = MemoryImage(kTransparentImage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var text = _getMessageStateData(context).text;
    BorderRadius imageBorderRadius = getImageBorderRadius(context, text);
    return BlocListener(
      bloc: _messageAttachmentBloc,
      listener: (context, state){
        if(state is MessageAttachmentStateSuccess){
          setState(() {
            if(state.path.isNotEmpty) {
              File file = File(state.path);
              imageProvider = FileImage(file);
              durationString = state.duration;
            }
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              AspectRatio(
                child: ClipRRect(
                  borderRadius: imageBorderRadius,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                aspectRatio: 4 / 3,
              ),
              Visibility(
                visible: widget.isVideo,
                child: Positioned.fill(
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: videoPreviewIconBackgroundHeight,
                        width: videoPreviewIconBackgroundWidth,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: black.withOpacity(fade),
                        ),
                        child: AdaptiveIcon(
                          icon: IconSource.play,
                          size: iconMessagePlaySize,
                          color: white,
                        ),
                      )),
                ),
              ),
              Visibility(
                visible: widget.isVideo && durationString.isNotEmpty,
                child: Positioned(
                  bottom: videoPreviewTimePositionBottom,
                  left: videoPreviewTimePositionLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(videoPreviewTimeBorderRadius),
                      color: black.withOpacity(fade),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: videoPreviewTimePaddingVertical, horizontal: videoPreviewTimePaddingHorizontal),
                      child: Text(
                        durationString,
                        style: Theme.of(context).textTheme.caption.apply(color: white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: text.isNotEmpty,
            child: Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: messagesVerticalPadding,
                    bottom: messagesVerticalInnerPadding,
                    left: messagesHorizontalInnerPadding,
                    right: messagesHorizontalInnerPadding),
                child: Text(text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius getImageBorderRadius(BuildContext context, String text) {
    var messageBorderRadius = MessageData.of(context).borderRadius;
    var messageStateData = _getMessageStateData(context);
    if (messageStateData.isGroup && !messageStateData.isOutgoing && text.isNotEmpty) {
      messageBorderRadius = BorderRadius.zero;
    } else if (messageStateData.isGroup && !messageStateData.isOutgoing && text.isEmpty) {
      messageBorderRadius = BorderRadius.only(bottomLeft: messageBorderRadius.bottomLeft, bottomRight: messageBorderRadius.bottomRight);
    } else if (text.isNotEmpty) {
      messageBorderRadius = BorderRadius.only(topLeft: messageBorderRadius.topLeft, topRight: messageBorderRadius.topRight);
    }
    return messageBorderRadius;
  }
}

class MessagePartGenericAttachment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var text = _getMessageStateData(context).text;
    AttachmentStateData attachment = _getMessageStateData(context).attachmentStateData;
    return Padding(
      padding: getNamePaddingForGroups(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: iconTextPadding),
                child: AdaptiveIcon(
                  icon: IconSource.attachFile,
                  size: messagesFileIconSize,
                  color: MessageData.of(context).textColor,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      attachment.filename,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(byteToPrintableSize(attachment.size)),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: text.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: messagesVerticalInnerPadding),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDateTime extends StatelessWidget {
  final int timestamp;
  final bool hasDateMarker;
  final bool showTime;

  const MessageDateTime({Key key, @required this.timestamp, this.hasDateMarker = false, this.showTime = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date;
    if (hasDateMarker && showTime) {
      date = "${getDateFromTimestamp(timestamp, true, true)} - ${getTimeFormTimestamp(timestamp)}";
    } else if (hasDateMarker) {
      date = getDateFromTimestamp(timestamp, true, true);
    } else {
      date = getTimeFormTimestamp(timestamp);
    }
    return Center(
      child: Text(
        date,
        style: TextStyle(
          color: onSurface.withOpacity(fade),
        ),
      ),
    );
  }
}

class MessagePartTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String time = getTimeFormTimestamp(_getMessageStateData(context).timestamp);
    return Text(
      time,
      style: TextStyle(color: MessageData.of(context).secondaryTextColor),
    );
  }
}

class MessagePartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageItemBloc, MessageItemState>(
      builder: (context, state) {
        if (state is MessageItemStateSuccess) {
          var messageState = state.messageStateData.state;
          if (messageState == ChatMsg.messageStateDelivered || messageState == ChatMsg.messageStateReceived) {
            IconSource icon = messageState == ChatMsg.messageStateDelivered ? IconSource.done : IconSource.doneAll;
            return Padding(
              padding: EdgeInsets.only(top: 10.0, left: iconTextPadding),
              child: AdaptiveIcon(
                icon: icon,
                size: 16.0,
                color: MessageData.of(context).secondaryTextColor,
              ),
            );
          }
        }
        return Container(width: 20.0);
      },
    );
  }
}

class MessagePartFlag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageItemBloc, MessageItemState>(
      builder: (context, state) {
        return Visibility(
          visible: state is MessageItemStateSuccess && state.messageStateData.isFlagged,
          child: Padding(
            padding: EdgeInsets.only(top: 8.0, right: 4.0, left: 4.0),
            child: AdaptiveIcon(
              icon: IconSource.flag,
              color: Colors.yellow,
            ),
          ),
        );
      },
    );
  }
}

EdgeInsetsGeometry getNamePaddingForGroups(BuildContext context) {
  var messageStateData = _getMessageStateData(context);
  if (messageStateData.isGroup && !messageStateData.isOutgoing) {
    return EdgeInsets.only(
      top: 2.0,
      bottom: messagesVerticalInnerPadding,
      left: messagesHorizontalInnerPadding,
      right: messagesHorizontalInnerPadding,
    );
  } else {
    return EdgeInsets.symmetric(vertical: messagesVerticalInnerPadding, horizontal: messagesHorizontalInnerPadding);
  }
}
