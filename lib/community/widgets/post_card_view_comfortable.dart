import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/bloc/account_bloc.dart';

import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_actions.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCardViewComfortable extends StatelessWidget {
  final Function(VoteType) onVoteAction;
  final Function(bool) onSaveAction;

  final PostViewMedia postViewMedia;
  final bool showThumbnailPreviewOnRight;
  final bool hideNsfwPreviews;
  final bool edgeToEdgeImages;
  final bool showTitleFirst;
  final bool showInstanceName;
  final bool showPostAuthor;
  final bool showFullHeightImages;
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showCommunityIcons;
  final bool showTextContent;
  final bool isUserLoggedIn;
  final bool markPostReadOnMediaView;
  final PostListingType? listingType;

  const PostCardViewComfortable({
    super.key,
    required this.postViewMedia,
    required this.showThumbnailPreviewOnRight,
    required this.hideNsfwPreviews,
    required this.edgeToEdgeImages,
    required this.showTitleFirst,
    required this.showInstanceName,
    required this.showPostAuthor,
    required this.showFullHeightImages,
    required this.showVoteActions,
    required this.showSaveAction,
    required this.showCommunityIcons,
    required this.showTextContent,
    required this.isUserLoggedIn,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.markPostReadOnMediaView,
    required this.listingType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    final showCommunitySubscription = (listingType == PostListingType.all || listingType == PostListingType.local) &&
        isUserLoggedIn &&
        context.read<AccountBloc>().state.subsciptions.map((subscription) => subscription.community.actorId).contains(postViewMedia.postView.community.actorId);

    final String textContent = postViewMedia.postView.post.body ?? "";
    final TextStyle? textStyleCommunityAndAuthor = theme.textTheme.bodyMedium?.copyWith(
      color: postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) : theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
    );

    var mediaView = MediaView(
      showLinkPreview: state.showLinkPreviews,
      postView: postViewMedia,
      showFullHeightImages: showFullHeightImages,
      hideNsfwPreviews: hideNsfwPreviews,
      edgeToEdgeImages: edgeToEdgeImages,
      markPostReadOnMediaView: markPostReadOnMediaView,
      isUserLoggedIn: isUserLoggedIn,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitleFirst)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
              child: Text(postViewMedia.postView.post.name,
                  textScaleFactor: state.titleFontSizeScale.textScaleFactor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: postViewMedia.postView.read ? theme.textTheme.titleMedium?.color?.withOpacity(0.4) : null,
                  ),
                  softWrap: true),
            ),
          if (edgeToEdgeImages) mediaView,
          if (!edgeToEdgeImages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: mediaView,
            ),
          if (!showTitleFirst)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 6.0, left: 12.0, right: 12.0),
              child: Text(postViewMedia.postView.post.name,
                  textScaleFactor: state.titleFontSizeScale.textScaleFactor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: postViewMedia.postView.read ? theme.textTheme.titleMedium?.color?.withOpacity(0.4) : null,
                  ),
                  softWrap: true),
            ),
          Visibility(
            visible: showTextContent && textContent.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 12.0, right: 12.0),
              child: Text(
                textContent,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: postViewMedia.postView.read ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 12.0, right: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostCommunityAndAuthor(
                        showCommunityIcons: false,
                        showInstanceName: showInstanceName,
                        postView: postViewMedia.postView,
                        textStyleCommunity: textStyleCommunityAndAuthor,
                        textStyleAuthor: textStyleCommunityAndAuthor,
                        showCommunitySubscription: showCommunitySubscription,
                      ),
                      const SizedBox(height: 8.0),
                      PostCardMetaData(
                        score: postViewMedia.postView.counts.score,
                        voteType: postViewMedia.postView.myVote ?? VoteType.none,
                        comments: postViewMedia.postView.counts.comments,
                        unreadComments: postViewMedia.postView.unreadComments,
                        hasBeenEdited: postViewMedia.postView.post.updated != null ? true : false,
                        published: postViewMedia.postView.post.updated != null ? postViewMedia.postView.post.updated! : postViewMedia.postView.post.published,
                        saved: postViewMedia.postView.saved,
                        distinguised: postViewMedia.postView.post.featuredCommunity,
                      )
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      semanticLabel: 'Actions',
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      showPostActionBottomModalSheet(
                        context,
                        postViewMedia,
                        actionsToInclude: [
                          PostCardAction.visitProfile,
                          PostCardAction.visitCommunity,
                          PostCardAction.blockCommunity,
                          PostCardAction.sharePost,
                          PostCardAction.shareMedia,
                          PostCardAction.shareLink,
                        ],
                      );
                      HapticFeedback.mediumImpact();
                    }),
                if (isUserLoggedIn)
                  PostCardActions(
                    postId: postViewMedia.postView.post.id,
                    voteType: postViewMedia.postView.myVote ?? VoteType.none,
                    saved: postViewMedia.postView.saved,
                    onVoteAction: onVoteAction,
                    onSaveAction: onSaveAction,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
