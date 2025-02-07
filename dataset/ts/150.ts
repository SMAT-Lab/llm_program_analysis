import { Mark, mergeAttributes } from '@tiptap/core'
import type { StyleParseRule } from '@tiptap/pm/model'
export interface SubscriptExtensionOptions {
  HTMLAttributes: Object,
}
declare module '@tiptap/core' {
  interface Commands<ReturnType> {
    subscript: {
      setSubscript: () => ReturnType,
      toggleSubscript: () => ReturnType,
      unsetSubscript: () => ReturnType,
    }
  }
}
export const Subscript = Mark.create<SubscriptExtensionOptions>({
  name: 'subscript',
  addOptions() {
    return {
      HTMLAttributes: {},
    }
  },
  parseHTML() {
    return [
      {
        tag: 'sub',
      },
      {
        style: 'vertical-align',
        getAttrs(value) {
          // Don’t match this rule if the vertical align isn’t sub.
          if (value !== 'sub') {
            return false
          }
          // If it falls through we’ll match, and this mark will be applied.
          return null
        },
      } as StyleParseRule,
    ]
  },
  renderHTML({ HTMLAttributes }) {
    return ['sub', mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0]
  },
  addCommands() {
    return {
      setSubscript: () => ({ commands }) => {
        return commands.setMark(this.name)
      },
      toggleSubscript: () => ({ commands }) => {
        return commands.toggleMark(this.name)
      },
      unsetSubscript: () => ({ commands }) => {
        return commands.unsetMark(this.name)
      },
    }
  },
  addKeyboardShortcuts() {
    return {
      'Mod-,': () => this.editor.commands.toggleSubscript(),
    }
  },
})