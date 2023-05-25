public class CampaignMemberHelper {
    public static void preventCMemberDelete(User usr, CampaignMember cMemb) {
        if(usr.profile.Name != 'Cegid Telemarketing' && usr.profile.Name != 'Cegid Marketing' 
        && usr.profile.Name != 'System Administrator' && usr.profile.Name != 'Administrateur Système' && usr.profile.Name != 'Marketo') {
            cMemb.addError('You can\'t delete campaign member');
        }
    }
}