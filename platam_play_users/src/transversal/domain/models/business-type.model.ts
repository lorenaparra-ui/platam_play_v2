export class BusinessType {
  constructor(
    public readonly id: number,
    public readonly name: string,
    public readonly description: string,
    public readonly isActive: boolean,
  ) {}
}