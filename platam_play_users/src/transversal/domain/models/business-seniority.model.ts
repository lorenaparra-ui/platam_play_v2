export class BusinessSeniority {
  constructor(
    public readonly id: number,
    public readonly name: string,
    public readonly level: number,
    public readonly isActive: boolean,
  ) {}
}