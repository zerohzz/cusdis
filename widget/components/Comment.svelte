<script>
  import { getContext } from 'svelte'
  import { t } from '../i18n'

  import Reply from './Reply.svelte'
  export let comment
  export let showReplyForm = false
  export let isChild = false

  const { showIndicator } = getContext('attrs')

  // #7: relative timestamp
  function timeAgo(dateStr) {
    const d = new Date(dateStr)
    const now = new Date()
    const diff = Math.floor((now - d) / 1000)
    if (diff < 60) return 'just now'
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`
    if (diff < 2592000) return `${Math.floor(diff / 86400)}d ago`
    return d.toLocaleDateString()
  }
</script>

<!-- #5 + #6: card style + accent left border for children -->
<div
  class="my-3 p-4 rounded-lg border border-gray-100 bg-gray-50 dark:bg-gray-800 dark:border-gray-700"
  class:cusdis-child={isChild}
  class:cusdis-indicator={showIndicator}
>
  <div class="flex items-center">
    <div class="mr-2 font-medium dark:text-gray-100">
      {comment.moderator && comment.moderator.displayName ? comment.moderator.displayName : comment.by_nickname}
    </div>

    {#if comment.moderatorId}
      <!-- #8: accent MOD badge -->
      <div class="mr-2 text-xs font-medium rounded-full" style="background-color: #AF8F6F; color: white; padding: 2px 8px; font-size: 0.65rem; letter-spacing: 0.05em;">
        <span>{t('mod_badge')}</span>
      </div>
    {/if}
  </div>

  <!-- #7: relative time with full date on hover -->
  <div class="text-gray-500 text-sm dark:text-gray-400" title={comment.parsedCreatedAt}>
    {timeAgo(comment.createdAt)}
  </div>

  <div class="text-gray-500 my-2 dark:text-gray-200">
    {@html comment.parsedContent}
  </div>

  {#if comment.replies.data.length > 0}
    {#each comment.replies.data as child (child.id)}
      <svelte:self isChild={true} comment={child} />
    {/each}
  {/if}

  <div>
    <button
      class="font-medium text-sm text-gray-500 dark:bg-transparent dark:text-gray-100"
      type="button"
      on:click={(_) => {
        showReplyForm = !showReplyForm
      }}>{t('reply_btn')}</button
    >
  </div>

  {#if showReplyForm}
    <div class="mt-4">
      <Reply
        parentId={comment.id}
        onSuccess={() => {
          showReplyForm = false
        }}
      />
    </div>
  {/if}
</div>

<style>
  /* #6: accent left border for nested replies */
  .cusdis-child {
    border-left: 3px solid #AF8F6F !important;
    margin-left: 1rem;
  }
</style>
