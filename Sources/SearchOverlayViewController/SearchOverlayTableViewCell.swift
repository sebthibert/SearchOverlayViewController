import UIKit

@available(iOS 13.0, *)
public enum SearchOverlayTableViewCell {
  case cellWithNib(UITableViewCell.Type)
  case cellWithClass(UITableViewCell.Type)
}
