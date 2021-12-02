import UIKit
import AgoraRtcKit
import Firebase
import SDWebImage

protocol LiveVCDataSource: NSObjectProtocol {
    func liveVCNeedAgoraKit() -> AgoraRtcEngineKit
    func liveVCNeedSettings() -> Settings
}

class LiveRoomViewController: UIViewController {
    
    @IBOutlet weak var tblComment :UITableView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var tfComments: UITextField!
    @IBOutlet weak var btnGift: UIButton!
    
    @IBOutlet weak var firstName : UILabel!
    @IBOutlet weak var lastName : UILabel!
    @IBOutlet weak var userImg : UIImageView!
    
    @IBOutlet weak var broadcastersView: AGEVideoContainer!
    @IBOutlet weak var placeholderView: UIImageView!
    
    @IBOutlet weak var videoMuteButton: UIButton!
    @IBOutlet weak var audioMuteButton: UIButton!
    @IBOutlet weak var beautyEffectButton: UIButton!
    
    @IBOutlet var sessionButtons: [UIButton]!
    
    
    var isAudiance = true
    var userImgString = ""
    var userNameString = ""
    var userData = [userMVC]()
    var commentsArr = [[String:Any]]()
    var myUser:[User]? {didSet{}}
    
    private let beautyOptions: AgoraBeautyOptions = {
        let options = AgoraBeautyOptions()
        options.lighteningContrastLevel = .normal
        options.lighteningLevel = 0.7
        options.smoothnessLevel = 0.5
        options.rednessLevel = 0.1
        return options
    }()
    
    private var agoraKit: AgoraRtcEngineKit {
        return dataSource!.liveVCNeedAgoraKit()
    }
    
    private var settings: Settings {
        return dataSource!.liveVCNeedSettings()
    }
    
    private var isMutedVideo = false {
        didSet {
            // mute local video
            agoraKit.muteLocalVideoStream(isMutedVideo)
            videoMuteButton.isSelected = isMutedVideo
        }
    }
    
    private var isMutedAudio = false {
        didSet {
            // mute local audio
            agoraKit.muteLocalAudioStream(isMutedAudio)
            audioMuteButton.isSelected = isMutedAudio
        }
    }
    
    private var isBeautyOn = false {
        didSet {
            // improve local render view
            agoraKit.setBeautyEffectOptions(isBeautyOn,
                                            options: isBeautyOn ? beautyOptions : nil)
            beautyEffectButton.isSelected = isBeautyOn
        }
    }
    
    private var isSwitchCamera = false {
        didSet {
            agoraKit.switchCamera()
        }
    }
    
    private var videoSessions = [VideoSession]() {
        didSet {
            placeholderView.isHidden = (videoSessions.count == 0 ? false : true)
            // update render view layout
            updateBroadcastersView()
        }
    }
    
    private let maxVideoSession = 4
    
    weak var dataSource: LiveVCDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblComment.delegate = self
        tblComment.dataSource = self
        
        setup()
        updateButtonsVisiablity()
        loadAgoraKit()
    }
    
    func setup(){
        self.Comments()
        if isAudiance == true{
            self.btnGift.isHidden =  false
            self.userImg.sd_imageIndicator = SDWebImageActivityIndicator.white
            self.userImg.sd_setImage(with: URL(string: (AppUtility?.detectURL(ipString: self.userImgString))!), placeholderImage: #imageLiteral(resourceName: "noUserImg"))
            
            self.firstName.text = userNameString

            print(settings.roomName)
            
        }else{
            self.btnGift.isHidden =  true
            let obj = userData[0]

            self.userImg.sd_imageIndicator = SDWebImageActivityIndicator.white
            self.userImg.sd_setImage(with: URL(string: (AppUtility?.detectURL(ipString: obj.userProfile_pic))!), placeholderImage: #imageLiteral(resourceName: "noUserImg"))
            
            self.firstName.text = obj.first_name
            self.lastName.text = obj.last_name
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeUser(notification:)), name: Notification.Name("removeLiveUserNoti"), object: nil)


    }
    @objc func removeUser(notification: Notification) {
      // Take Action on Notification
        
        leaveChannel()
        AppUtility?.dismissPopAllViewViewControllers()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - ui action
    @IBAction func btnShareCoins(_ sender: Any) {
        let userID = UserDefaults.standard.string(forKey: "userID")
        if userID == ""{
            print("Please Login")
            return
        }
        let vc =  storyboard?.instantiateViewController(withIdentifier: "CoinShareVC") as! CoinShareViewController
        vc.userData = self.userData
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func doSwitchCameraPressed(_ sender: UIButton) {
        isSwitchCamera.toggle()
    }
    
    @IBAction func doBeautyPressed(_ sender: UIButton) {
        isBeautyOn.toggle()
    }
    
    @IBAction func doMuteVideoPressed(_ sender: UIButton) {
        isMutedVideo.toggle()
    }
    
    @IBAction func doMuteAudioPressed(_ sender: UIButton) {
        isMutedAudio.toggle()
    }
    
    @IBAction func doLeavePressed(_ sender: UIButton) {
        leaveChannel()
        
    }
    
    
}

private extension LiveRoomViewController {
    func updateBroadcastersView() {
        // video views layout
        if videoSessions.count == maxVideoSession {
            broadcastersView.reload(level: 0, animated: true)
        } else {
            var rank: Int
            var row: Int
            
            if videoSessions.count == 0 {
                broadcastersView.removeLayout(level: 0)
                return
            } else if videoSessions.count == 1 {
                rank = 1
                row = 1
            } else if videoSessions.count == 2 {
                rank = 1
                row = 2
            } else {
                rank = 2
                row = Int(ceil(Double(videoSessions.count) / Double(rank)))
            }
            
            let itemWidth = CGFloat(1.0) / CGFloat(rank)
            let itemHeight = CGFloat(1.0) / CGFloat(row)
            let itemSize = CGSize(width: itemWidth, height: itemHeight)
            let layout = AGEVideoLayout(level: 0)
                        .itemSize(.scale(itemSize))
            
            broadcastersView
                .listCount { [unowned self] (_) -> Int in
                    return self.videoSessions.count
                }.listItem { [unowned self] (index) -> UIView in
                    return self.videoSessions[index.item].hostingView
                }
            
            broadcastersView.setLayouts([layout], animated: true)
        }
    }
    
    func updateButtonsVisiablity() {
        guard let sessionButtons = sessionButtons else {
            return
        }
        
        let isHidden = settings.role == .audience
        
        for item in sessionButtons {
            item.isHidden = isHidden
        }
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
}

private extension LiveRoomViewController {
    func getSession(of uid: UInt) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(of uid: UInt) -> VideoSession {
        if let fetchedSession = getSession(of: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
}

//MARK: - Agora Media SDK
private extension LiveRoomViewController {
    func loadAgoraKit() {
        guard let channelId = settings.roomName else {
            return
        }
        
        setIdleTimerActive(false)
        agoraKit.delegate = self
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(settings.role)
        agoraKit.enableDualStreamMode(true)
    
        agoraKit.enableVideo()
        agoraKit.setVideoEncoderConfiguration(
            AgoraVideoEncoderConfiguration(
                size: settings.dimension,
                frameRate: settings.frameRate,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: .adaptative
            )
        )
        
        if settings.role == .broadcaster {
            addLocalSession()
            agoraKit.startPreview()
        }
    
        agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channelId, info: nil, uid: 0, joinSuccess: nil)
        agoraKit.setEnableSpeakerphone(true)
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        localSession.updateInfo(fps: settings.frameRate.rawValue)
        videoSessions.append(localSession)
        agoraKit.setupLocalVideo(localSession.canvas)
    }
    
    func leaveChannel() {
  
        agoraKit.setupLocalVideo(nil)
        agoraKit.leaveChannel(nil)
        if settings.role == .broadcaster {
            agoraKit.stopPreview()
            
            self.myUser = User.readUserFromArchive()
            let reference = Database.database().reference()
            let LiveUser = reference.child("LiveUsers").child((self.myUser?[0].id)!).removeValue()
            
        }
        
        setIdleTimerActive(true)
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - AgoraRtcEngineDelegate
extension LiveRoomViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        if let selfSession = videoSessions.first {
            selfSession.updateInfo(resolution: size)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        if let selfSession = videoSessions.first {
            selfSession.updateChannelStats(stats)
        }
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        guard videoSessions.count <= maxVideoSession else {
            return
        }
        
        let userSession = videoSession(of: uid)
        userSession.updateInfo(resolution: size)
        agoraKit.setupRemoteVideo(userSession.canvas)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerated() where session.uid == uid {
            indexToDelete = index
            break
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            
            // release canvas's view
            deletedSession.canvas.view = nil
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        if let session = getSession(of: stats.uid) {
            session.updateVideoStats(stats)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        if let session = getSession(of: stats.uid) {
            session.updateAudioStats(stats)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning code: \(warningCode.description)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("warning code: \(errorCode.description)")
    }
}

//Mark Comments Work
extension LiveRoomViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsNewTVC", for: indexPath) as! commentsNewTableViewCell
        
        cell.userName.text =  (self.commentsArr[indexPath.row]["userName"] as? String ?? "unknown User")
        cell.comment.text =  (self.commentsArr[indexPath.row]["comment"] as! String)
        cell.userImg.sd_imageIndicator = SDWebImageActivityIndicator.white
        cell.userImg.sd_setImage(with: URL(string: (AppUtility?.detectURL(ipString: (self.commentsArr[indexPath.row]["userPicture"] as? String ?? "unknown User")))!), placeholderImage: #imageLiteral(resourceName: "noUserImg"))
 
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @IBAction func btnSendComment(_ sender: UIButton) {
        AddCommentsToLiveChat()
    }
    
    
    func Comments(){

        let childRef = Database.database().reference().child("LiveUsers").child(settings.roomName!).child("Chat")
            
            childRef.observe(DataEventType.value, with: { (snapshot) in
                self.commentsArr.removeAll()
                for cmnt in snapshot.children.allObjects as! [DataSnapshot] {
                    let artistObject = cmnt.value as? [String: AnyObject]
                    self.commentsArr.append(artistObject!)
                    self.scrollToBottom()
                    print(artistObject!)
                    self.tblComment.reloadData()
                    
                }
            })
    }
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.commentsArr.count-1, section: 0)
            self.tblComment.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func AddCommentsToLiveChat(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ssZ"
        let resultDate = formatter.string(from: date)

        print("currentDateTime",resultDate)
        
        var myUser: [User]? {didSet {}}
        myUser = User.readUserFromArchive()

        let reference = Database.database().reference()
        let LiveUser = reference.child("LiveUsers").child(settings.roomName!).child("Chat").childByAutoId()
  
        
        var parameters = [String : Any]()
        parameters = [
            "comment"                   : self.tfComments.text!,
            "commentTime"               : resultDate,
            "key"                       : LiveUser.key,
            "type"                      : "comment",
            "userId"                    : myUser![0].id,
            "userName"                  : myUser![0].username ,
            "userPicture"               : AppUtility?.detectURL(ipString: self.myUser?[0].profile_pic ?? "") ?? ""
            
        ]
        
        LiveUser.setValue(parameters) { [self](error, ref) in
            if error != nil{
                print(error ?? "")
                return
            }
        }
        self.tfComments.text =  nil
        
    }
}
