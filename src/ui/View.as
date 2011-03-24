package ui
{
  import flash.display.DisplayObjectContainer;
  import lib.Point;
  import lib.ChangeList;
  import lib.ui.ButtonList;
  import lib.ui.ImageList;
  import lib.ui.Keyboard;
  import lib.ui.MenuList;
  import lib.ui.Window;

  import logic.ButtonStatus;
  import logic.Map;
  import logic.Model;

  import ui.menu.ButtonMenu;
  import ui.menu.EditMenu;
  import ui.menu.GoalMenu;
  import ui.menu.PlaceMenu;
  import ui.menu.TileMenu;
  import ui.menu.VictoryMenu;
  import ui.menu.PartMenu;

  import ui.menu.MovieMenu;
  import ui.menu.SystemMenu;

  public class View
  {
    public function View(newParent : DisplayObjectContainer,
                         newKeyboard : lib.ui.Keyboard,
                         backgroundSize : Point) : void
    {
      parent = newParent;
      keyboard = newKeyboard;
      images = new lib.ui.ImageList();
      anims = new AnimList();
      border = new FactoryBorder(FactoryBorder.GRASS);
      window = new lib.ui.Window(parent,
                                 new Point(Main.WIDTH,
                                           Main.HEIGHT - MENU_HEIGHT),
                                 backgroundSize, ImageConfig.layerCount,
                                 images, border, new WindowBackgroundClip(),
                                 100);
      window.scrollWindow(window.getCenter());
      wirePlace = new WirePlace(parent, keyboard, window);
      wireParent = new WireParent(parent, window);
      wireParent.hide();
      goalPlace = new GoalPlace(parent, window, images);
      tabs = new TabList(parent, window, goalPlace, wirePlace, wireParent);
      movieMenu = new MovieMenu(parent, window);
      partPlace = new PartPlace(parent, keyboard, window);
      scrollMenu = new ScrollMenu(parent, window, keyboard, true);
      tip = new ToolTipClip();
      parent.addChild(tip);
      tip.visible = false;
      systemMenu = new SystemMenu(parent);
      explosions = [];
    }

    public function cleanup() : void
    {
      for each (var explosion in explosions)
      {
        explosion.cleanup();
      }
      systemMenu.cleanup();
      tip.parent.removeChild(tip);
      scrollMenu.cleanup();
      tabs.cleanup();
      movieMenu.cleanup();
      goalPlace.cleanup();
      wireParent.cleanup();
      wirePlace.cleanup();
      partPlace.cleanup();
      window.cleanup();
      images.cleanup();
    }

    public function enterFrame() : void
    {
      scrollMenu.enterFrame();
      var i = 0;
      for (; i < Model.FRAME_COUNT; ++i)
      {
        anims.enterFrame();
      }
      images.update(window);
      tabs.enterFrame();
      while (explosions.length > 0 && explosions[0].isDone())
      {
        explosions[0].cleanup();
        explosions.splice(0, 1);
      }
      movieMenu.enterFrame();
    }

    public function startPlay() : void
    {
      wireParent.startPlay();
      if (settings.isMovie())
      {
        partPlace.hide();
        goalPlace.hide();
      }
    }

    public function stopPlay() : void
    {
      wireParent.stopPlay();
    }

    public function declareVictory() : void
    {
      tabs.setMenu(TabList.VICTORY_MENU);
    }

    public function getParent() : DisplayObjectContainer
    {
      return parent;
    }

    public function getImages() : lib.ui.ImageList
    {
      return images;
    }

    public function getWindow() : lib.ui.Window
    {
      return window;
    }

    public function getWireParent() : WireParent
    {
      return wireParent;
    }

    public function getAnims() : AnimList
    {
      return anims;
    }

    public function addExplosion(newExplosion : ExplosionView) : void
    {
      explosions.push(newExplosion);
    }

    public function setModel(newSettings : GameSettings,
                             changes : lib.ChangeList,
                             map : logic.Map,
                             saveMap : Function,
                             goals : Array,
                             forEachPart : Function,
                             endGame : Function,
                             countParts : Function,
                             countSteps : Function,
                             countCreated : Function,
                             countBroken : Function)
    {
      settings = newSettings;
      partPlace.setModel(changes, map, settings.isEditor(), tabs.setMenu);
      wirePlace.setModel(changes, map, tabs.getWireText(), wireParent);
      movieMenu.setModel(settings, endGame, saveMap);
      goalPlace.setModel(goals, map, tabs.refreshMenu);
      tabs.setModel(settings, changes, map, forEachPart, endGame, saveMap,
                    partPlace, countParts, countSteps, countCreated,
                    countBroken, tip);
      border.setModel(scrollMenu.getVertical(), scrollMenu.getHorizontal(),
                      partPlace);
      window.scrollWindow(new Point(0, 0));
      systemMenu.setModel(endGame, saveMap, settings);
    }

    var parent : DisplayObjectContainer;
    var keyboard : lib.ui.Keyboard;
    var images : lib.ui.ImageList;
    var anims : AnimList;
    var window : lib.ui.Window;
    var border : FactoryBorder;
    var settings : GameSettings;
    var partPlace : PartPlace;
    var wirePlace : WirePlace;
    var wireParent : WireParent;
    var goalPlace : GoalPlace;
    var movieMenu : ui.menu.MovieMenu;
    var tabs : TabList;
    var scrollMenu : ScrollMenu;
    var systemMenu : ui.menu.SystemMenu;
    var explosions : Array;
    var tip : ToolTipClip;

    public static var MENU_HEIGHT = 75;
  }
}