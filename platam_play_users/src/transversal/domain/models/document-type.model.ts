export class DocumentType {
  constructor(
    public readonly id: number,
    public readonly name: string,
    public readonly code: string,
    public readonly isActive: boolean,
  ) {}
}