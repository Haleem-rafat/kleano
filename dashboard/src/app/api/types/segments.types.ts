export interface IAllSegment {
  createdAt: Date;
  name: string;
  updatedAt: Date;
  users: string[];
  _id: string;
}

export interface ISegment {
  createdAt: Date;
  name: string;
  updatedAt: Date;
  users: { userName: string; email: string; _id: string }[];
  _id: string;
}
