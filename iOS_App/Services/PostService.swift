//
//  PostService.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 31.03.2025.
//

import Network
import Foundation

public class PostService {
    
    private let fileManager = FileManager.default
    private weak var delegate: LoadNewPostsDelegate?
    private var savedPosts: [Post] = []
    var posts: [Post] = []
    let subreddit = "ios"
    
    var after: String?
    var isFetching = false
    var isLastPost = false
    var isInternetAvaible = true
    
    private var filePath: URL {
        var documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsDirectory.appendPathComponent("saved_posts.json")
        return documentsDirectory
    }
    
    init(delegate: LoadNewPostsDelegate?) {
        self.delegate = delegate
        
        Task {
            if await !isInternetAvailable() {
                isInternetAvaible = false
            }
        }
    }
    
    func loadInitialPosts() {
        loadSavedPosts()
        fetchData()
    }
    
    func loadSavedPosts() {
        guard fileManager.fileExists(atPath: filePath.path(percentEncoded: false)) else {
            return
        }
            
        do {
            let data = try Foundation.Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            let postsFromFile = try decoder.decode([Post].self, from: data)
            self.savedPosts = postsFromFile
        } catch {
            print("Не вдалося завантажити пости з файлу: \(error.localizedDescription)")
        }
    }

    func savePosts() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(savedPosts)
            try data.write(to: filePath, options: .atomic)
        } catch {
            print("Не вдалося зберегти пости в файл: \(error.localizedDescription)")
        }
    }

    func savePost(_ post: Post) {
        guard !savedPosts.contains(post) else { return }
        savedPosts.append(post)
        savePosts()
        loadSavedPosts()
    }
    
    func removePost(_ post: Post) {
        savedPosts.customRemove(post: post)
        if let index = posts.firstIndex(where: { $0 == post }) {
                posts[index].saved = false
        }
        savePosts()
        loadSavedPosts()
    }
    
    public func fetchData() {
        guard !isFetching && !isLastPost else { return }
        guard isInternetAvaible else {
            if (posts.isEmpty) {
                self.posts = savedPosts.map { Post(post: $0.post, saved: $0.saved)}
            }
            delegate?.redrowTable()
            return
        }
        isFetching = true
        
        
        
        Task {
            let redditPostsResponse = try await RedditAPIClient.shared.fetchPosts(
                subreddit: subreddit,
                limit: 20,
                after: after)
            if let afterStr = redditPostsResponse.data.after {
                after = afterStr
            } else {
                isLastPost = true
            }
            
            var fetchedPosts: [Post] = []
            for post in redditPostsResponse.data.children {
                let newPost = Post(post: post, saved: false)
                if savedPosts.customContains(post: newPost) {
                    newPost.saved = true
                    fetchedPosts.append(newPost)
                } else {
                    fetchedPosts.append(newPost)
                }
            }
            
            self.posts.append(contentsOf: fetchedPosts)
            self.isFetching = false
            delegate?.redrowTable()
        }
    }
    
    func isInternetAvailable() async -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitorQueue")
        
        return await withCheckedContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
                
                monitor.cancel()
            }
            
            monitor.start(queue: queue)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                monitor.cancel()
            }
        }
    }
    
    func getFilteredSavedPosts(title: String) -> [Post] {
        if title.isEmpty {
            return savedPosts
        }
        return savedPosts.filter { $0.post.data.title.lowercased().contains(title.lowercased()) }
    }
}
