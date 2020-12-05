import SwiftUI
import Introspect

struct PullToRefresh: UIViewRepresentable {
    let onRefresh: (_ endRefreshing: @escaping () -> Void) -> Void
    
    public init(onRefresh: @escaping (_ endRefreshing: @escaping () -> Void) -> Void) {
        self.onRefresh = onRefresh
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }
    
    private func tableView(entry: UIView) -> UITableView? {
        // Search in ancestors
        if let tableView = Introspect.findAncestor(ofType: UITableView.self, from: entry) {
            return tableView
        }

        guard let viewHost = Introspect.findViewHost(from: entry) else {
            return nil
        }

        // Search in siblings
        return Introspect.previousSibling(containing: UITableView.self, from: viewHost)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            guard let tableView = self.tableView(entry: uiView) else {
                return
            }
            
            //NO MORE
//            if let refreshControl = tableView.refreshControl {
//                if self.isShowing {
//                    refreshControl.beginRefreshing()
//                } else {
//                    refreshControl.endRefreshing()
//                }
//                return
//            }
            
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onRefresh: onRefresh)
    }
    
    class Coordinator: NSObject {
        let refreshControl: RefreshControl
        let onRefresh: (_ endRefreshing: @escaping () -> Void) -> Void
        
        init(_ refreshControl: RefreshControl, onRefresh: @escaping (_ endRefreshing: @escaping () -> Void) -> Void) {
            self.refreshControl = refreshControl
            self.onRefresh = onRefresh
        }
        
        @objc
        func handleRefreshControl(sender: UIRefreshControl) {
            //IT NEEDS TO BE HANDLED FROM HERE
            onRefresh() {
                sender.endRefreshing()
            }
        }
    }
}

extension View {
    public func pullToRefresh(onRefresh: @escaping (_ endRefreshing: @escaping () -> Void) -> Void) -> some View {
        return overlay(
            RefreshControl(onRefresh: onRefresh)
                .frame(width: 0, height: 0)
        )
    }
}
