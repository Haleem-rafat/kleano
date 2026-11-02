'use client';

import * as React from 'react';
import * as TabsPrimitive from '@radix-ui/react-tabs';

import { cn } from '@/shadecn/lib/utils';
import { segmentGroup, segmentItem } from '@/shadecn/lib/field';

const Tabs = TabsPrimitive.Root;

const TabsList = React.forwardRef<
  React.ElementRef<typeof TabsPrimitive.List>,
  React.ComponentPropsWithoutRef<typeof TabsPrimitive.List>
>(({ className, ...props }, ref) => {
  const innerRef = React.useRef<HTMLDivElement | null>(null);

  // Keep the selected tab visible when the bar scrolls sideways (many tabs, small screens).
  React.useEffect(() => {
    const list = innerRef.current;
    if (!list) return;
    const reveal = () => {
      const active = list.querySelector<HTMLElement>('[data-state="active"]');
      if (!active) return;
      const start = active.offsetLeft - list.offsetLeft;
      const end = start + active.offsetWidth;
      if (start < list.scrollLeft) list.scrollLeft = start - 8;
      else if (end > list.scrollLeft + list.clientWidth)
        list.scrollLeft = end - list.clientWidth + 8;
    };
    reveal();
    const observer = new MutationObserver(reveal);
    observer.observe(list, { attributes: true, subtree: true, attributeFilter: ['data-state'] });
    return () => observer.disconnect();
  }, []);

  return (
    <TabsPrimitive.List
      ref={(node) => {
        innerRef.current = node;
        if (typeof ref === 'function') ref(node);
        else if (ref) ref.current = node;
      }}
      className={cn(segmentGroup, className)}
      {...props}
    />
  );
});
TabsList.displayName = TabsPrimitive.List.displayName;

const TabsTrigger = React.forwardRef<
  React.ElementRef<typeof TabsPrimitive.Trigger>,
  React.ComponentPropsWithoutRef<typeof TabsPrimitive.Trigger>
>(({ className, ...props }, ref) => (
  <TabsPrimitive.Trigger ref={ref} className={cn(segmentItem, className)} {...props} />
));
TabsTrigger.displayName = TabsPrimitive.Trigger.displayName;

const TabsContent = React.forwardRef<
  React.ElementRef<typeof TabsPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof TabsPrimitive.Content>
>(({ className, ...props }, ref) => (
  <TabsPrimitive.Content
    ref={ref}
    className={cn(
      'mt-4 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
      className
    )}
    {...props}
  />
));
TabsContent.displayName = TabsPrimitive.Content.displayName;

export { Tabs, TabsList, TabsTrigger, TabsContent };
