import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:thunder/user/pages/user_page.dart';

import '../../core/auth/bloc/auth_bloc.dart';

class CommentHeader extends StatelessWidget {
  final CommentViewTree commentViewTree;
  final bool useDisplayNames;
  final bool isOwnComment;
  final bool isHidden;
  final bool isCommentNew;

  const CommentHeader({
    super.key,
    required this.commentViewTree,
    required this.useDisplayNames,
    this.isCommentNew = false,
    this.isOwnComment = false,
    this.isHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;

    VoteType? myVote = commentViewTree.commentView?.myVote;
    bool? saved = commentViewTree.commentView?.saved;
    bool? hasBeenEdited = commentViewTree.commentView!.comment.updated != null ? true : false;
    //int score = commentViewTree.commentViewTree.comment?.counts.score ?? 0; maybe make combined scores an option?
    int upvotes = commentViewTree.commentView?.counts.upvotes ?? 0;
    int downvotes = commentViewTree.commentView?.counts.downvotes ?? 0;

    int level = commentViewTree.level;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Tooltip(
                  excludeFromSemantics: true,
                  message: '${commentViewTree.commentView!.creator.name}@${fetchInstanceNameFromUrl(commentViewTree.commentView!.creator.actorId) ?? '-'}${fetchUsernameDescriptor(isOwnComment)}',
                  preferBelow: false,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          account_bloc.AccountBloc accountBloc = context.read<account_bloc.AccountBloc>();
                          AuthBloc authBloc = context.read<AuthBloc>();
                          ThunderBloc thunderBloc = context.read<ThunderBloc>();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: accountBloc),
                                  BlocProvider.value(value: authBloc),
                                  BlocProvider.value(value: thunderBloc),
                                ],
                                child: UserPage(userId: commentViewTree.commentView!.creator.id),
                              ),
                            ),
                          );
                        },
                        child: isSpecialUser(context, isOwnComment)
                            ? Container(
                                decoration:
                                    BoxDecoration(color: fetchUsernameColor(context, isOwnComment) ?? theme.colorScheme.onBackground, borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        commentViewTree.commentView!.creator.displayName != null && useDisplayNames
                                            ? commentViewTree.commentView!.creator.displayName!
                                            : commentViewTree.commentView!.creator.name,
                                        textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.white),
                                      ),
                                      const SizedBox(width: 2.0),
                                      Container(
                                        child: isOwnComment
                                            ? Padding(
                                                padding: const EdgeInsets.only(left: 1),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 15.0 * state.contentFontSizeScale.textScaleFactor,
                                                  color: Colors.white,
                                                ))
                                            : Container(),
                                      ),
                                      // Container(
                                      //   // TODO: Figure out how to determine mods
                                      //   child: true
                                      //     ? Padding(
                                      //       padding: const EdgeInsets.only(left: 1),
                                      //       child: Icon(
                                      //         Thunder.shield,
                                      //         size: 14.0 * state.contentFontSizeScale.textScaleFactor,
                                      //         color: Colors.white,
                                      //       ),
                                      //     )
                                      //     : Container(),
                                      // ),
                                      Container(
                                        child: commentViewTree.commentView?.creator.admin == true
                                            ? Padding(
                                                padding: const EdgeInsets.only(left: 1),
                                                child: Icon(
                                                  Thunder.shield_crown,
                                                  size: 14.0 * state.contentFontSizeScale.textScaleFactor,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Container(
                                        child: commentViewTree.commentView != null && commentViewTree.commentView?.post.creatorId == commentViewTree.commentView?.comment.creatorId
                                            ? Padding(
                                                padding: const EdgeInsets.only(left: 1),
                                                child: Icon(
                                                  Thunder.microphone_variant,
                                                  size: 15.0 * state.contentFontSizeScale.textScaleFactor,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Text(
                                commentViewTree.commentView!.creator.displayName != null && useDisplayNames
                                    ? commentViewTree.commentView!.creator.displayName!
                                    : commentViewTree.commentView!.creator.name,
                                textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
                Icon(
                  Icons.north_rounded,
                  size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                  color: myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                ),
                const SizedBox(width: 2.0),
                Text(
                  formatNumberToK(upvotes),
                  semanticsLabel: '${formatNumberToK(upvotes)} upvotes',
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: myVote == VoteType.up ? Colors.orange : theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(width: 10.0),
                Icon(
                  Icons.south_rounded,
                  size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                  color: downvotes != 0 ? (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
                ),
                const SizedBox(width: 2.0),
                if (downvotes != 0)
                  Text(
                    formatNumberToK(downvotes),
                    semanticsLabel: '${formatNumberToK(upvotes)} downvotes',
                    textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: downvotes != 0 ? (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground) : Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              AnimatedOpacity(
                opacity: (isHidden && (collapseParentCommentOnGesture || (commentViewTree.commentView?.counts.childCount ?? 0) > 0)) ? 1 : 0,
                // Matches the collapse animation
                duration: const Duration(milliseconds: 130),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Text(
                      '+${commentViewTree.commentView!.counts.childCount}',
                      textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                saved == true ? Icons.star_rounded : null,
                color: saved == true ? Colors.purple : null,
                size: saved == true ? 18.0 : 0,
              ),
              SizedBox(
                width: hasBeenEdited ? 32.0 : 8,
                child: Icon(
                  hasBeenEdited ? Icons.create_rounded : null,
                  color: theme.colorScheme.onBackground.withOpacity(0.75),
                  size: 16.0,
                ),
              ),
              Container(
                decoration: isCommentNew ? BoxDecoration(color: theme.splashColor, borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))) : null,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      isCommentNew
                          ? const Row(children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 16.0,
                              ),
                              SizedBox(width: 5)
                            ])
                          : Container(),
                      Text(
                        commentViewTree.datePostedOrEdited,
                        textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Color? fetchUsernameColor(BuildContext context, bool isOwnComment) {
    CommentView commentView = commentViewTree.commentView!;
    final theme = Theme.of(context);

    if (isOwnComment) return theme.colorScheme.primary;
    if (commentView.creator.admin == true) return theme.colorScheme.tertiary;
    if (commentView.post.creatorId == commentView.comment.creatorId) return theme.colorScheme.secondary;

    return null;
  }

  String fetchUsernameDescriptor(bool isOwnComment) {
    CommentView commentView = commentViewTree.commentView!;

    String descriptor = '';

    if (isOwnComment) descriptor += 'me';
    if (commentView.creator.admin == true) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}admin';
    if (commentView.post.creatorId == commentView.comment.creatorId) descriptor += '${descriptor.isNotEmpty ? ', ' : ''}original poster';

    if (descriptor.isNotEmpty) descriptor = ' ($descriptor)';

    return descriptor;
  }

  bool isSpecialUser(BuildContext context, bool isOwnComment) {
    CommentView commentView = commentViewTree.commentView!;

    return isOwnComment || commentView.creator.admin == true || commentView.post.creatorId == commentView.comment.creatorId;
  }
}
