import AirqoLogo from '../../../../public/icons/airqo_logo.svg';
import HelpCenterIcon from '../../../../public/icons/help_center.svg';
import NotificationsIcon from '../../../../public/icons/notifications.svg';
import ArrowDropDownIcon from '../../../../public/icons/arrow_drop_down.svg';

const TopBar = () => {
  return (
    <div className='fixed top-0 flex justify-between items-center w-full p-4 h-16 box-border border border-[#E8E8E8] bg-white'>
      <AirqoLogo className='w-[46.56px] h-8' />

      <div className='w-[452.97px]'>
        <input
          type='text'
          className='w-full h-10 rounded-[4px] bg-[#0000000A] outline-0 text-black'
        />
      </div>

      <div className='flex'>
        <div className='border border-[#E8E8E8] w-10 h-10 rounded-lg ml-3 p-[10px]'>
          <HelpCenterIcon className='w-5 h-5 stroke-[#00000014] opacity-30' />
        </div>
        <div className='border border-[#E8E8E8] w-10 h-10 rounded-lg ml-3 py-[10px] px-3'>
          <NotificationsIcon className='w-4 h-5 stroke-[#00000014] opacity-30' />
        </div>
        <div className='border border-[#E8E8E8] w-full h-10 p-2 box-border rounded-lg flex items-center justify-between ml-3'>
          <div className='flex mr-[22.5px]'>
            <div className='bg-[#DDDDDD] w-6 h-6 p-[5px] rounded-full mr-3'>
              <h3 className='text-[10px] font-normal'>DO</h3>
            </div>
            <h3>Deo Okedi</h3>
          </div>
          <ArrowDropDownIcon />
        </div>
      </div>
    </div>
  );
};

export default TopBar;
