import React from 'react';
import { IoStar, IoStarOutline } from 'react-icons/io5';

interface StarRatingProps {
  rating: number;
  maxRating?: number;
  size?: 'sm' | 'md' | 'lg';
  showValue?: boolean;
  className?: string;
}

export default function StarRating({
  rating,
  maxRating = 5,
  size = 'md',
  showValue = true,
  className = '',
}: StarRatingProps) {
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-5 w-5',
    lg: 'h-6 w-6',
  };

  const textSizeClasses = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  };

  const stars = [];
  for (let i = 1; i <= maxRating; i++) {
    stars.push(
      <span key={i} className="text-yellow-400">
        {i <= rating ? (
          <IoStar className={sizeClasses[size]} />
        ) : (
          <IoStarOutline className={sizeClasses[size]} />
        )}
      </span>
    );
  }

  return (
    <div className={`flex items-center gap-1 ${className}`}>
      <div className="flex items-center gap-0.5">{stars}</div>
      {showValue && (
        <span className={`ml-2 font-medium text-slate-700 ${textSizeClasses[size]}`}>
          {rating.toFixed(1)}
        </span>
      )}
    </div>
  );
}
