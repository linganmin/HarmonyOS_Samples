export interface SongInfoItem{
  /**
   *  Randomly generated unique ID
   */
  uuid: string;
  /**
   *  Resource id
   */
  id: string;
  /**
   *  Resource title
   */
  title: string
  /**
   *  Resource brief
   */
  brief?: string
  /**
   *  Resource type
   */
  type: string
  /**
   *  Resource detail Web URL
   */
  webUrl: string
  /**
   *  Resource publish date
   */
  publishDate: Date
  /**
   *  Resource cover image used on card
   */
  headerImageUrl: string
  /**
   *  Topics to which the resource belongs.
   */
  topics: string[]
  /**
   *  Resource views count
   */
  viewsCount: number
  /**
   *  Resource collection count
   */
  collectionCount: number
  /**
   *  Resource likes count
   */
  likesCount: number
  /**
   *  Resource tag
   */
  tag: string
  /**
   *  Indicates whether the resource is added to likes list of the current user.
   */
  isLiked: boolean
  /**
   *  Indicates whether the resource is added to favorites of the current user
   */
  isCollected: boolean
  /**
   *  Whether the resource has been browsed by the current user
   */
  isViewed: boolean
  /**
   *  Resource detail media URL
   */
  mediaSrc: string
  /**
   *  Resource banner image URL
   */
  bannerSrc: string
  cachedImage:ESObject
  songId:number
  albumUrl:string
}

export class  PageViewModel{
  static getItems(): import("../model/LearningResource").LearningResource[] {
    throw new Error('Method not implemented.')
  }
}
