import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { EditorContent, useEditor, type Editor } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Underline from '@tiptap/extension-underline';
import Link from '@tiptap/extension-link';
import TextAlign from '@tiptap/extension-text-align';
import Placeholder from '@tiptap/extension-placeholder';
import {
  Bold,
  Italic,
  Underline as UnderlineIcon,
  Heading2,
  Heading3,
  List,
  ListOrdered,
  Link as LinkIcon,
  AlignLeft,
  AlignCenter,
  AlignRight,
  Undo2,
  Redo2,
  Pilcrow,
} from 'lucide-react';
import { cn } from '@/shadecn/lib/utils';

/** Old plain-text content (no tags) becomes paragraphs so it opens cleanly in the editor. */
export const toEditorHtml = (value?: string) => {
  if (!value) return '';
  if (/<\/?[a-z][\s\S]*>/i.test(value)) return value;
  return value
    .split(/\n{2,}/)
    .map(
      (block) =>
        `<p>${block.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/\n/g, '<br>')}</p>`
    )
    .join('');
};

interface IRichTextEditorProps {
  value: string;
  onChange: (html: string) => void;
  placeholder?: string;
  dir?: 'ltr' | 'rtl';
  readOnly?: boolean;
  className?: string;
}

const ToolButton = ({
  onClick,
  active,
  disabled,
  label,
  children,
}: {
  onClick: () => void;
  active?: boolean;
  disabled?: boolean;
  label: string;
  children: React.ReactNode;
}) => (
  <button
    type="button"
    onMouseDown={(e) => e.preventDefault()}
    onClick={onClick}
    disabled={disabled}
    aria-label={label}
    aria-pressed={active}
    title={label}
    className={cn(
      'flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground disabled:pointer-events-none disabled:opacity-40',
      active && 'bg-accent text-primary'
    )}>
    {children}
  </button>
);

const Divider = () => <span className="mx-1 h-5 w-px shrink-0 bg-border" />;

const Toolbar = ({ editor }: { editor: Editor }) => {
  const { t } = useTranslation();
  const setLink = () => {
    const prev = editor.getAttributes('link').href as string | undefined;
    const url = window.prompt(t('linkUrl'), prev || 'https://');
    if (url === null) return;
    if (url === '' || url === 'https://') {
      editor.chain().focus().extendMarkRange('link').unsetLink().run();
      return;
    }
    editor.chain().focus().extendMarkRange('link').setLink({ href: url }).run();
  };
  const i = 'h-4 w-4';
  return (
    <div
      role="toolbar"
      aria-label={t('formatting')}
      className="sticky top-0 z-[1] flex items-center gap-0.5 overflow-x-auto border-b border-border bg-card/95 px-2 py-1.5 backdrop-blur [scrollbar-width:none]">
      <ToolButton
        label={t('paragraph')}
        active={editor.isActive('paragraph')}
        onClick={() => editor.chain().focus().setParagraph().run()}>
        <Pilcrow className={i} />
      </ToolButton>
      <ToolButton
        label={t('heading')}
        active={editor.isActive('heading', { level: 2 })}
        onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()}>
        <Heading2 className={i} />
      </ToolButton>
      <ToolButton
        label={t('subheading')}
        active={editor.isActive('heading', { level: 3 })}
        onClick={() => editor.chain().focus().toggleHeading({ level: 3 }).run()}>
        <Heading3 className={i} />
      </ToolButton>
      <Divider />
      <ToolButton
        label={t('bold')}
        active={editor.isActive('bold')}
        onClick={() => editor.chain().focus().toggleBold().run()}>
        <Bold className={i} />
      </ToolButton>
      <ToolButton
        label={t('italic')}
        active={editor.isActive('italic')}
        onClick={() => editor.chain().focus().toggleItalic().run()}>
        <Italic className={i} />
      </ToolButton>
      <ToolButton
        label={t('underline')}
        active={editor.isActive('underline')}
        onClick={() => editor.chain().focus().toggleUnderline().run()}>
        <UnderlineIcon className={i} />
      </ToolButton>
      <ToolButton label={t('link')} active={editor.isActive('link')} onClick={setLink}>
        <LinkIcon className={i} />
      </ToolButton>
      <Divider />
      <ToolButton
        label={t('bulletList')}
        active={editor.isActive('bulletList')}
        onClick={() => editor.chain().focus().toggleBulletList().run()}>
        <List className={i} />
      </ToolButton>
      <ToolButton
        label={t('numberedList')}
        active={editor.isActive('orderedList')}
        onClick={() => editor.chain().focus().toggleOrderedList().run()}>
        <ListOrdered className={i} />
      </ToolButton>
      <Divider />
      <ToolButton
        label={t('alignStart')}
        active={editor.isActive({ textAlign: 'left' })}
        onClick={() => editor.chain().focus().setTextAlign('left').run()}>
        <AlignLeft className={i} />
      </ToolButton>
      <ToolButton
        label={t('alignCenter')}
        active={editor.isActive({ textAlign: 'center' })}
        onClick={() => editor.chain().focus().setTextAlign('center').run()}>
        <AlignCenter className={i} />
      </ToolButton>
      <ToolButton
        label={t('alignEnd')}
        active={editor.isActive({ textAlign: 'right' })}
        onClick={() => editor.chain().focus().setTextAlign('right').run()}>
        <AlignRight className={i} />
      </ToolButton>
      <Divider />
      <ToolButton
        label={t('undo')}
        disabled={!editor.can().undo()}
        onClick={() => editor.chain().focus().undo().run()}>
        <Undo2 className={i} />
      </ToolButton>
      <ToolButton
        label={t('redo')}
        disabled={!editor.can().redo()}
        onClick={() => editor.chain().focus().redo().run()}>
        <Redo2 className={i} />
      </ToolButton>
    </div>
  );
};

/** Rich text with headings, emphasis, lists, links and alignment. Outputs HTML. */
export default function RichTextEditor({
  value,
  onChange,
  placeholder,
  dir = 'ltr',
  readOnly = false,
  className,
}: IRichTextEditorProps) {
  const editor = useEditor({
    extensions: [
      StarterKit.configure({ heading: { levels: [2, 3] } }),
      Underline,
      Link.configure({ openOnClick: false, autolink: true }),
      TextAlign.configure({ types: ['heading', 'paragraph'] }),
      Placeholder.configure({ placeholder: placeholder || '' }),
    ],
    content: toEditorHtml(value),
    editable: !readOnly,
    editorProps: {
      attributes: { dir, class: 'rich-text min-h-[16rem] px-4 py-3 focus:outline-none' },
    },
    onUpdate: ({ editor: e }) => onChange(e.isEmpty ? '' : e.getHTML()),
  });

  // Load server content once it arrives (and after Cancel), without fighting the cursor.
  useEffect(() => {
    if (!editor) return;
    const next = toEditorHtml(value);
    if (next !== editor.getHTML() && !(next === '' && editor.isEmpty)) {
      editor.commands.setContent(next, false);
    }
  }, [value, editor]);

  useEffect(() => {
    editor?.setEditable(!readOnly);
  }, [readOnly, editor]);

  return (
    <div
      className={cn(
        'overflow-hidden rounded-lg border border-input bg-card transition-[border-color,box-shadow] focus-within:border-primary focus-within:shadow-[0_0_0_3px_hsl(var(--primary)/0.15)]',
        readOnly && 'border-border bg-muted/30',
        className
      )}>
      {editor && !readOnly && <Toolbar editor={editor} />}
      <EditorContent editor={editor} />
    </div>
  );
}
