@ObservedV2
export class ConfigStorage {
  @Trace colorMode: number = 0;
  @Trace language: string = 'en';
  private static instance: ConfigStorage | null = null;

  static getInstance(): ConfigStorage {
    if (ConfigStorage.instance === null) {
      ConfigStorage.instance = new ConfigStorage();
    }
    return ConfigStorage.instance;
  }

  public updateConfig(colorMode?: number, language?: string): void {
    this.updateColorMode(colorMode);
    this.updateLanguage(language);
  }

  public updateColorMode(colorMode?: number) {
    if (colorMode !== undefined) {
      this.colorMode = colorMode;
    }
  }

  public updateLanguage(language?: string) {
    if (language !== undefined) {
      this.language = language;
    }
  }
}